#!/usr/bin/env python3

"""Self contained GeneCall module."""

from __future__ import print_function
import sys
import argparse
import time
import json
import numpy as np
import os
import re
import tensorflow as tf
from keras.models import load_model
from sklearn.preprocessing import LabelEncoder


dnaAll = 'acgtuwsmkrybdhvnz-'
dnaEncoder = LabelEncoder()
dnaEncoder.fit(np.array(list(dnaAll)).flatten())

dna2rev = {
    'a': 't',
    'c': 'g',
    'g': 'c',
    't': 'a',
    'u': 'a',
    'w': 'w',
    's': 's',
    'm': 'k',
    'k': 'm',
    'r': 'y',
    'y': 'r',
    'b': 'v',
    'd': 'h',
    'h': 'd',
    'v': 'b',
    'n': 'n',
    'z': 'z',
    '-': '-',
}

def dna_reverse_complement(dna):
    return ''.join(dna2rev[i] for i in list(reversed(dna)))

def to_sparse_categorical(arr, encoder=None, fit=None, returnEncoder=False):
    """Convert arbitrary categories into numeric categories, and optionally return the encoder."""
    arr = np.array(arr)
    if encoder is not None:
        labelEncoder = encoder
        labels = labelEncoder.transform(arr.flatten()).reshape(arr.shape)
    else:
        labelEncoder = LabelEncoder()

        if fit is not None:
            labels = labelEncoder.fit(fit.flatten())
            labels = labelEncoder.transform(arr.flatten()).reshape(arr.shape)
        else:
            labels = labelEncoder.fit_transform(arr.flatten()).reshape(arr.shape)

    if returnEncoder:
        return labels, labelEncoder
    else:
        return labels

def select_gpu(num, verbose=True):
    """Set the visible GPU's to Keras."""
    if verbose:
        print('Using GPU', str(num), file=sys.stderr)

    os.environ['CUDA_VISIBLE_DEVICES'] = str(num)

def tf_nowarn():
    """Suppress as many warning messages as possible from Tensorflow."""
    # Suppress Tensorflow warnings
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

    # Suppress OpenMP warnings
    os.environ['KMP_WARNINGS'] = 'FALSE'

    # Set Tensorflow log level to only errors
    tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)

class Genome(object):
    """A Genome object facilitates reading and organizing contigs."""

    def __init__(self, gid=None, source=None):
        self.gid = gid
        self.source = source
        self.contigs = []
        self.gtoDict = {}
        self.last_id = 0
        # TODO: Change contigs to a dictionary

        if source is not None:
            if os.path.isfile(source+'.fna'):
                self.add_fasta(source+'.fna')
            if os.path.isfile(source+'.fsa'):
                self.add_fasta(source+'.fsa')

            if os.path.isfile(source+'.PATRIC.gff'):
                self.add_gff(source+'.PATRIC.gff')
            if os.path.isfile(source+'.gff'):
                self.add_gff(source+'.gff')

            if os.path.isfile(source+'.bam'):
                self.add_bam(source+'.bam')

    def __str__(self):
        rv = ''

        if self.gid is not None:
            rv += ' name=' + self.gid.__repr__()

        if self.source is not None:
            rv += ' source=' + self.source.__repr__()

        rv += '; ' + str(len(self.contigs)) + ' contigs'
        rv += f'; {sum(len(c.dnaPos) for c in self.contigs):,} bp; {100*self.gc:0.1f}% gc'

        return '<Genome' + rv + '>'

    def __repr__(self):
        return self.__str__()

    def get_contig_by_id(self, cid):
        # TODO: Delete this function once the contigs are stored in a dictionary
        for c in self.contigs:
            if c.cid == cid:
                return c
        return None

    def add_fasta(self, fname):
        """Extracts the sequences from a fasta file into the appropriate contigs."""

        contig2dna = read_fasta(fname)

        for contigId, dna in contig2dna.items():
            c = self.get_contig_by_id(contigId)
            if c is None:
                c = Contig(cid=contigId, genome=self)
                self.contigs.append(c)
            c.dnaPos = dna

    def add_gff(self, fname):
        """Extracts the features from a .gff file into the appropriate contigs."""

        contig2features = read_gff(fname)

        for contigId, features in contig2features.items():
            c = self.get_contig_by_id(contigId)
            if c is None:
                c = Contig(cid=contigId, genome=self)
                self.contigs.append(c)
            c.features.extend(features)

    def add_bam(self, fname):
        """Reads .bam and .bam.bai files and computes an RNA-Seq pileup for the sequence."""

        with pysam.AlignmentFile(fname, 'rb') as f:
            for contigId in sorted(f.references):
                # contigIdx = int(contigId.split('con.')[-1])
                # c = self.contigs[contigIdx-1]

                c = self.get_contig_by_id(contigId)
                l = f.lengths[f.references.index(contigId)]

                rnaProfile = np.zeros((l+1,))

                pile = f.pileup(contig=contigId)
                for x in pile:
                    rnaProfile[x.reference_pos] = min(x.nsegments, 100)

                c.rnaProfile = rnaProfile

    @property
    def gc(self):
        """Calculates the average GC content of all contigs."""

        return sum(c.gc*len(c.dnaPos) for c in self.contigs) / sum(len(c.dnaPos) for c in self.contigs)

class Contig(object):
    """A Contig stores a sequence and the features on that sequence."""

    def __init__(self, cid=None, genome=None):
        self.cid = cid
        self.genome = genome
        self.geneticCode = None
        self._dnaPos = None
        self._dnaNeg = None
        self.gc = None
        self.rnaProfile = None
        self.coding = None
        self.features = []
        self.orfs = []

    def __str__(self):
        rv = ''

        if self.cid is not None:
            rv += ' name=' + self.cid.__repr__()

        if self.dnaPos is not None:
            rv += f'; {len(self.dnaPos):,} bp; {100*self.gc:0.1f}% gc'

        if self.rnaProfile is not None:
            rv += '; has RNA'

        rv += '; ' + str(len(self.features)) + ' features'
        rv += '; ' + str(len(self.orfs)) + ' orfs'

        return '<Contig' + rv + '>'

    def __repr__(self):
        return self.__str__()

    def annotate_coding(self, quiet=False):
        """Create a label for each base pair denoting the coding frame, if any."""

        if not quiet:
            print('WARNING: Minus strand calculation might have off by 1.', file=sys.stderr)

        if not self.dnaPos or not self.features:
            return

        self.coding = np.zeros(len(self.dnaPos))

        for feature in self.features:
            if feature.featureType != 'CDS':
                continue

            if feature.strand == '+':
                for frame, i in enumerate(range(feature.left, feature.right)):
                    self.coding[i] = frame%3 + 1
            else:
                for frame, i in enumerate(range(feature.left, feature.right)):
                    self.coding[i] = frame%3 - 3

    def find_orfs(self):
        """Traverses the sequence finding all ORFs on both strands."""

        self._find_orfs(self.dnaPos, '+')
        self._find_orfs(self.dnaNeg, '-')

    def _find_orfs(self, dna, strand):
        # Store all start codons, organized by frame
        naL = [[], [], []]
        for match in re.finditer(r'(?=[agt]tg)', dna):
            loc = match.start()
            frame = loc%3
            naL[frame].append(loc)

        # Store all stop codons, organized by frame
        noL = [[0], [1], [2]]
        for match in re.finditer(r'(?=taa|tag|tga)', dna):
            loc = match.start()
            frame = loc%3
            noL[frame].append(loc+3)

        # Find all collections of start codons in frame with stops (ORFs)
        for frame in range(3):
            j = -1
            for i in range(len(noL[frame])-1):
                front = noL[frame][i]
                back = noL[frame][i+1]

                # Find all of the potential starts in this ORF to reduce computation later
                starts = []
                for j in range(j+1, len(naL[frame])):
                    # Once we are outside the ORF, stop searching
                    if naL[frame][j] >= back:
                        j -= 1
                        break
                    starts.append(naL[frame][j])

                # Create an ORF if this section of dna has at least one in-frame start
                if len(starts) > 0:
                    if strand == '+':
                        orf = ORF(front, back, starts, strand, frame)
                    else:
                        orf = ORF(len(dna)-back, len(dna)-front, list(reversed([len(dna)-start for start in starts])), strand, frame)
                    self.orfs.append(orf)

    def mark_coding_orfs(self, realFeatures):
        """Records which ORFs contain an in-frame feature, and where that feature starts."""

        orfsPos = {o.right:o for o in self.orfs if o.strand == '+'}
        orfsNeg = {o.left:o for o in self.orfs if o.strand == '-'}

        featuresPos = [f for f in realFeatures if f.strand == '+']
        featuresNeg = [f for f in realFeatures if f.strand == '-']

        # Find all features sharing a stop (right) with an ORF on the + strand
        for feature in featuresPos:
            if feature.right in orfsPos:
                orfsPos[feature.right].realStart = feature.left

        # Find all features sharing a stop (left) with an ORF on the - strand
        for feature in featuresNeg:
            if feature.left in orfsNeg:
                orfsNeg[feature.left].realStart = feature.right

    @property
    def dnaPos(self):
        return self._dnaPos
    @dnaPos.setter
    def dnaPos(self, dnaPos):
        self._dnaPos = dnaPos
        self._dnaNeg = dna_reverse_complement(dnaPos)

        a = self._dnaPos.count('a')
        c = self._dnaPos.count('c')
        g = self._dnaPos.count('g')
        t = self._dnaPos.count('t')
        self.gc = (g+c) / (a+c+g+t)

    @property
    def dnaNeg(self):
        return self._dnaNeg
    @dnaNeg.setter
    def dnaNeg(self, dnaNeg):
        self._dnaNeg = dnaNeg
        self._dnaPos = dna_reverse_complement(dnaNeg)

        a = self._dnaPos.count('a')
        c = self._dnaPos.count('c')
        g = self._dnaPos.count('g')
        t = self._dnaPos.count('t')
        self.gc = (g+c) / (a+c+g+t)

class Feature(object):
    """A section of a sequence with various properties."""

    def __init__(self, contig, left, right, strand, featureType, source, other=''):
        self.contig = contig
        self.left = left
        self.right = right
        self.strand = strand
        self.featureType = featureType
        self.source = source
        self.other = other
        self.gtoDict = {}

    def __str__(self):
        rv = ''

        if self.contig is not None:
            rv += ' contig=' + self.contig.__repr__()

        if self.left is not None:
            rv += ' left=' + self.left.__repr__()

        if self.right is not None:
            rv += ' right=' + self.right.__repr__()

        if self.strand is not None:
            rv += ' strand=' + self.strand.__repr__()

        if self.featureType is not None:
            rv += ' featureType=' + self.featureType.__repr__()

        if self.source is not None:
            rv += ' source=' + self.source.__repr__()

        if self.other is not None:
            rv += ' other=' + self.other.__repr__()

        return '<Feature' + rv + '>'

    def __repr__(self):
        return self.__str__()

    def encode_gff(self):
        """Returns a .gff styled line corresponding to this feature."""

        return '\t'.join([
            self.contig,
            self.source,
            self.featureType,
            self.left,
            self.right,
            '.',
            self.strand,
            '0',
            self.other,
        ])

class ORF(object):
    """Specialized feature for open reading frames."""

    def __init__(self, left, right, starts, strand, frame):
        self.left = left
        self.right = right
        self.starts = starts
        self.strand = strand
        self.frame = frame
        self.scores = {}
        self.realStart = None

    def __str__(self):
        rv = ''

        if self.left is not None:
            rv += ' left=' + self.left.__repr__()

        if self.right is not None:
            rv += ' right=' + self.right.__repr__()

        if self.starts is not None:
            rv += ' starts=' + self.starts.__repr__()

        if self.strand is not None:
            rv += ' strand=' + self.strand.__repr__()

        if self.frame is not None:
            rv += ' frame=' + self.frame.__repr__()

        return '<ORF' + rv + '>'

    def __repr__(self):
        return self.__str__()

    @property
    def score(self):
        if self.scores is {}:
            return 0

        return max(self.scores.values())

def read_gto(fname):
    with open(fname) as f:
        data = json.load(f)

    figP = re.compile('fig\\|\\d+\\.\\d+\\.peg\\.(\\d+)')
    g = Genome(gid=data['id'])
    cid2c = {}

    for contig in data.pop('contigs'):
        c = Contig(cid=contig['id'], genome=g)
        c.dnaPos = contig['dna']
        c.geneticCode = contig['genetic_code']

        cid2c[c.cid] = c
        g.contigs.append(c)

    for feature in data.pop('features'):
        loc = feature.pop('location')[0]
        start = int(loc[1])-1
        length = int(loc[3])
        if loc[2] == '+':
            left = start
            right = start+length
        else:
            left = start-length+1
            right = start+1
        m = figP.match(feature['id'])
        if m:
            this_id = int(m.group(1))
            if g.last_id < this_id:
                g.last_id = this_id
            source = 'PATRIC'
        else:
            source = 'RMB'
        f = Feature(contig=loc[0], left=left, right=right, strand=loc[2], featureType=feature.pop('type'), source=source)
        f.gtoDict = feature
        cid2c[loc[0]].features.append(f)

    g.gtoDict = data

    return g

def save_gto(fname, genome):
    data = genome.gtoDict

    data['contigs'] = []
    data['features'] = []

    for contig in genome.contigs:
        cD = {}
        cD['id'] = contig.cid
        cD['dna'] = contig.dnaPos
        cD['genetic_code'] = contig.geneticCode
        data['contigs'].append(cD)

        for feature in contig.features:
            fD = feature.gtoDict
            fD['type'] = feature.featureType
            if feature.source == 'RMB':
                genome.last_id = genome.last_id + 1;
                evidence = fD['id']
                fD['id'] = 'fig|' + str(genome.gid) + '.peg.' + str(genome.last_id)
                fD['function'] = 'hypothetical protein'
                fD['annotations'] = [["Hypothetical protein found with evidence " + evidence, "export.RMB", time.time()]]
            if feature.strand == '+':
                fD['location'] = [[feature.contig, feature.left+1, feature.strand, feature.right-feature.left]]
            elif feature.strand == '-':
                fD['location'] = [[feature.contig, feature.right, feature.strand, feature.right-feature.left]]
            data['features'].append(fD)

    with open(fname, 'w') as f:
        json.dump(data, f, indent=3)

def calc_loc_preds(dna, starts, stops, genomeGC, contigGC, startL, startR, stopL, stopR, codingSize, startModel, stopModel, codingModel):
    startLocs = []
    startSamples = []
    startCodingSamples = []
    stopLocs = []
    stopSamples = []
    stopCodingSamples = []

    dna = np.array(to_sparse_categorical(list(dna), encoder=dnaEncoder))

    # Find all possible starts
    for location, geneLength, orfLength in starts:
        sample = dna[location-startL:location+3+startR]
        codingSample = dna[location+3+startR:location+3+startR+codingSize]

        # Sample might have been at the edge of a contig
        if len(sample) != startL+3+startR:
            # STILL AN ISSUE
            # print('WARNING: Edge of contig hit.', file=sys.stderr)
            continue
        if len(codingSample) != codingSize:
            # STILL AN ISSUE
            # print('WARNING: Edge of contig hit.', file=sys.stderr)
            continue

        startLocs.append(location)
        startSamples.append([sample, geneLength, orfLength, genomeGC, contigGC])
        startCodingSamples.append([codingSample, genomeGC, contigGC])

    # Find all possible stops
    for location, orfLength in stops:
        sample = dna[location-stopL:location+3+stopR]
        codingSample = dna[location-stopL-codingSize:location-stopL]

        # Sample might have been at the edge of a contig
        if len(sample) != stopL+3+stopR:
            # STILL AN ISSUE
            # print('WARNING: Edge of contig hit.', file=sys.stderr)
            continue
        if len(codingSample) != codingSize:
            # STILL AN ISSUE
            # print('WARNING: Edge of contig hit.', file=sys.stderr)
            continue

        stopLocs.append(location)
        stopSamples.append([sample, orfLength, genomeGC, contigGC])
        stopCodingSamples.append([codingSample, genomeGC, contigGC])

    startSamples = np.array(startSamples)
    stopSamples = np.array(stopSamples)
    startCodingSamples = np.array(startCodingSamples)
    stopCodingSamples = np.array(stopCodingSamples)

    # startSamples = np.array([to_sparse_categorical(list(s), encoder=dnaEncoder) for s in startSamples])
    # stopSamples = np.array([to_sparse_categorical(list(s), encoder=dnaEncoder) for s in stopSamples])
    # startCodingSamples = np.array([to_sparse_categorical(list(s), encoder=dnaEncoder) for s in startCodingSamples])
    # stopCodingSamples = np.array([to_sparse_categorical(list(s), encoder=dnaEncoder) for s in stopCodingSamples])

    if startSamples.size == 0 or stopSamples.size == 0 or startCodingSamples.size == 0 or stopCodingSamples.size == 0:
        return {}, {}, {}, {}

    # Process the start and stop dna segments
    startPreds = startModel.predict([np.vstack(startSamples[:,0]), startSamples[:,1], startSamples[:,2], startSamples[:,3], startSamples[:,4]], batch_size=4096)
    stopPreds = stopModel.predict([np.vstack(stopSamples[:,0]), stopSamples[:,1], stopSamples[:,2], stopSamples[:,3]], batch_size=4096)
    startCodingPreds = codingModel.predict([np.vstack(startCodingSamples[:,0]), startCodingSamples[:,1], startCodingSamples[:,2]], batch_size=4096)
    stopCodingPreds = codingModel.predict([np.vstack(stopCodingSamples[:,0]), stopCodingSamples[:,1], stopCodingSamples[:,2]], batch_size=4096)

    startLoc2Pred = dict(zip(startLocs, np.hstack(startPreds)))
    stopLoc2Pred = dict(zip(stopLocs, stopPreds))
    startLoc2CodingPred = dict(zip(startLocs, startCodingPreds))
    stopLoc2CodingPred = dict(zip(stopLocs, stopCodingPreds))

    return startLoc2Pred, stopLoc2Pred, startLoc2CodingPred, stopLoc2CodingPred

def combine_orf_preds(orf, startLoc2Pred, stopLoc2Pred, startLoc2CodingPred, stopLoc2CodingPred, dnalen=None):
    if orf.strand == '+':
        stop = orf.right-3
    elif orf.strand == '-':
        stop = dnalen-orf.left-3

    if stop not in stopLoc2Pred:
        # TODO: STILL AN ISSUE
        # print('WARNING: ORF is not in stopLoc2Pred. This may be a big issue.', file=sys.stderr)
        return [], [], []

    i = 0
    pointPredsL = []
    isCorrectL = []
    metaL = []
    for start in orf.starts:
        if orf.strand == '+':
            realStart = orf.realStart
            length = orf.right-start
        if orf.strand == '-':
            start = dnalen-start
            realStart = dnalen-orf.realStart if orf.realStart is not None else None
            length = start-orf.left

        if start not in startLoc2Pred:
            continue

        pointPredsL.append([
            *startLoc2Pred[start],
            *startLoc2CodingPred[start].flatten(),
            *stopLoc2CodingPred[stop].flatten(),
            # TODO: Check if start operator will work with stopLoc2Pred (and remove [0])
            stopLoc2Pred[stop][0],
            # TODO: Remove gene length? It is already part of the other predictors, no sense here too
            length,
        ])

        isCorrectL.append([
            1 if start==realStart else 0,
        ])

        if orf.strand == '+':
            metaL.append([
                start,
                orf.right,
            ])
        if orf.strand == '-':
            metaL.append([
                orf.left,
                dnalen-start,
            ])

        i += 1

    return pointPredsL, isCorrectL, metaL

def score_orfs(contig, genomeGC, contigGC, startL, startR, stopL, stopR, codingSize, cutoff, startModel, stopModel, codingModel, scoreModel, overwrite=False):
    startLoc2Pred, stopLoc2Pred, startLoc2CodingPred, stopLoc2CodingPred = calc_loc_preds(
        dna=contig.dnaPos,
        starts=[(start, orf.right-start, orf.right-orf.left) for orf in contig.orfs if orf.strand == '+' for start in orf.starts],
        stops=[(orf.right-3, orf.right-orf.left) for orf in contig.orfs if orf.strand == '+'],
        genomeGC=genomeGC,
        contigGC=contigGC,
        startL=90,
        startR=90,
        stopL=90,
        stopR=90,
        codingSize=33,
        startModel=startModel,
        stopModel=stopModel,
        codingModel=codingModel,
    )

    for orf in contig.orfs:
        if orf.strand != '+':
            continue


        if not overwrite:
            l = [f.right == orf.right for f in contig.features]
            if any(l):
                continue

        pointPreds, isCorrect, meta = combine_orf_preds(
            orf,
            startLoc2Pred,
            stopLoc2Pred,
            startLoc2CodingPred,
            stopLoc2CodingPred,
        )

        if len(pointPreds) == 0:
            continue

        pointPreds = np.array(pointPreds)
        scores = scoreModel.predict([pointPreds], batch_size=4096)

        for i in range(len(meta)):
            orf.scores[int(meta[i][0])] = float(scores[i])

        if scores.max() >= cutoff:
            # for sample in meta:
            best = meta[scores.argmax()]

            left = int(best[0])
            right = int(best[1])
            f = Feature(contig.cid, left, right, '+', 'CDS', 'RMB', other='rmbscore=%.6f'%(orf.scores[left]))
            f.gtoDict['id'] = 'RMB|%.6f'%(orf.scores[left])
            contig.features.append(f)

    ####################################################################################################
    ####################################################################################################
    ####################################################################################################

    startLoc2Pred, stopLoc2Pred, startLoc2CodingPred, stopLoc2CodingPred = calc_loc_preds(
        dna=contig.dnaNeg,
        starts=[(len(contig.dnaNeg)-start, start-orf.left, orf.right-orf.left) for orf in contig.orfs if orf.strand == '-' for start in orf.starts],
        stops=[(len(contig.dnaNeg)-orf.left-3, orf.right-orf.left) for orf in contig.orfs if orf.strand == '-'],
        genomeGC=genomeGC,
        contigGC=contigGC,
        startL=90,
        startR=90,
        stopL=90,
        stopR=90,
        codingSize=33,
        startModel=startModel,
        stopModel=stopModel,
        codingModel=codingModel,
    )

    for orf in contig.orfs:
        if orf.strand != '-':
            continue

        if not overwrite:
            l = [f.left == orf.left for f in contig.features]
            if any(l):
                continue

        pointPreds, isCorrect, meta = combine_orf_preds(
            orf,
            startLoc2Pred,
            stopLoc2Pred,
            startLoc2CodingPred,
            stopLoc2CodingPred,
            dnalen=len(contig.dnaNeg),
        )

        if len(pointPreds) == 0:
            continue

        pointPreds = np.array(pointPreds)
        scores = scoreModel.predict([pointPreds], batch_size=4096)

        for i in range(len(meta)):
            orf.scores[int(meta[i][1])] = float(scores[i])

        if scores.max() >= cutoff:
            # for sample in meta:
            best = meta[scores.argmax()]

            left = int(best[0])
            right = int(best[1])
            f = Feature(contig.cid, left, right, '-', 'CDS', 'RMB', other='rmbscore=%.6f'%(orf.scores[right]))
            f.gtoDict['id'] = 'RMB|%.6f'%(orf.scores[right])
            contig.features.append(f)

def main(args):
    if args.verbose:
        print('Loading genome', file=sys.stderr)
    genome = read_gto(args.input)

    if args.verbose:
        print('Loading models', file=sys.stderr)
    startModel = load_model(os.path.join(args.modelDirectory, 'start.h5'), compile=False)
    stopModel = load_model(os.path.join(args.modelDirectory, 'stop.h5'), compile=False)
    codingModel = load_model(os.path.join(args.modelDirectory, 'coding.h5'), compile=False)
    scoreModel = load_model(os.path.join(args.modelDirectory, 'score.h5'), compile=False)

    if args.verbose:
        print('Doing', genome, file=sys.stderr)
    genomeGC = genome.gc
    for contig in genome.contigs:
        contig.find_orfs()
        if args.verbose:
            print('  Doing', contig, file=sys.stderr)
        contigGC = contig.gc

        score_orfs(
            contig=contig,
            genomeGC=genomeGC,
            contigGC=contigGC,
            startL=90,
            startR=90,
            stopL=90,
            stopR=90,
            codingSize=33,
            cutoff=0.5,
            startModel=startModel,
            stopModel=stopModel,
            codingModel=codingModel,
            scoreModel=scoreModel,
            overwrite=False,
        )

    save_gto(args.output, genome)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose output')
    parser.add_argument('-g', '--gpu', type=str, default='-1', help='Comma separated list of GPUs to use')
    parser.add_argument('--input', type=str, help='GTO input file')
    parser.add_argument('--output', type=str, help='GTO output file')
    parser.add_argument('modelDirectory', type=str, help='Which directory the model is in')
    args = parser.parse_args()

    # Avoid the plethora of tensorflow debug messages
    tf_nowarn()
    select_gpu(args.gpu)

    main(args)
