import sys, os, pickle, json
sys.path.insert(0,'/tmp/econ3/ladder/scripts')
import sim
from multiprocessing import Pool
SET=sys.argv[1]
BD=['RifleZombie','PistolZombie','Labguy','ShotgunGuy1','SMGGuy','ChaingunGuy1','Imp','BullDemon','FatPinky','Spectro',
    'Cacodemon_','TehLostSoul','PainElemental1','HellKnight2','BaronofHell2','Revenant1','Mancubus','Volcabus','Arachnotron1',
    'Arachnotron2','AASpider','TehArchvile','TheCyberdemon','TheSpiderMastermind','BDMummy','BaronBoss1']
XM=['RifleZombie','LabGAL','ChainsawZombie','SniperRifleGuy','LabGuy','LabGuyB','LabGuyP','PlasmaZombie','MinigunGuy',
    'ShotgunGuy1','RiotShieldGuy','SuperShotgunZombie','ASGGuy','PyroSergeant','RocketGuy','QuadShotgunZombie','EvilMarine',
    'EvilMarineLasgun','Imp','Imp3','SuperImp','NetherDarkImp','VoidDarkImp','NamiDarkImp','DarkImp','Cacodemon_',
    'ImpureElemental','Overlord','AracnorbQueen','BaronofHell2','CyberBaron','BruiserDemon','PyroDemon','TerminatorDemon',
    'Minimastermind','Minimastermindx','Annihilator','TheCyberdemon','SuperDemon','Thamuz','ChaingunGuy1','Major',
    'RifleCommando','ZSpecOps','ZSpecOpsRail','ZSpecOpsRifle','XVStealthZSpecOps','HellTrooper','HellKnight2','CyberKnight',
    'Revenant1','Draugr','Incarnate','BullDemon','VoidSpectre','BloodDemon','TehArchvile','Mancubus','Daedabus','Volcabus',
    'SpidermastermindX','TheSpidermastermind','AracnorbQueenBOSS','PainElemental1','SufferingElemental','Arachnotron1',
    'CGSpider','Diabloist','TehLostSoul','Spectro']
if SET=='bd22':
    sim.load('/tmp/econ3/ladder/scripts/rsq_classes.pkl','/tmp/econ3/ladder/scripts/bd22_classes.pkl'); names=BD
else:
    sim.load('/tmp/econ3/ladder/scripts/rsq_classes.pkl','/tmp/econ3/ladder/scripts/bd22_classes.pkl','/tmp/econ3/ladder/scripts/xmve_classes.pkl'); names=XM
import analyze
analyze.sim = sim
OUT=f'/tmp/econ3/ladder/scripts/simres_{SET}.pkl'
def one(n):
    try: return analyze.one(n)
    except Exception as e: return n, {'error': repr(e)}
if __name__=='__main__':
    names=[n for n in names if sim.cls(n)]
    print('missing', [n for n in (BD if SET=='bd22' else XM) if not sim.cls(n)])
    done={}
    with Pool(2) as p:
        for n,o in p.imap_unordered(one, names):
            done[n]=o; print(n, 'err' if 'error' in o else round(o[256]['dps'],1), flush=True)
    pickle.dump(done, open(OUT,'wb'))
