"""Check content before embedding it. Run from any directory."""
import json, math, struct, wave
from pathlib import Path

root = Path(__file__).resolve().parents[1] / 'assets'
levels = sorted((root/'levels').glob('*.json'))
assert levels, 'Không có màn'
seen = set()
for path in levels:
    j = json.loads(path.read_text())
    assert j['id'] not in seen
    seen.add(j['id'])
    w,h = (j['board'][k] for k in ('width','height'))
    s = j['settings']
    assert min(w,h,s['snapRadius']) > 0 and 0 <= s['angleToleranceDegrees'] <= 180
    assert s['freeHints'] >= 0 and j['reward']['coins'] >= 0
    assert j['reward']['unlockMuseum'] == j['speciesId']
    ids = [b['id'] for b in j['bones']]
    crates = [c['id'] for c in j['crates']]
    packed = [i for c in j['crates'] for i in c['boneIds']]
    assert ids and len(ids)==len(set(ids)) and sorted(ids)==sorted(packed)
    assert len(set(crates))==len(crates)
    for b in j['bones']:
        png=(root/'images'/b['asset']).read_bytes()
        assert png[:8] == bytes.fromhex('89504e470d0a1a0a') and png[25]==6
        assert min(struct.unpack('>II',png[16:24])) > 0
        angle=math.radians(b['targetAngle'])
        for dx in [-b['width']/2,b['width']/2]:
            for dy in [-b['height']/2,b['height']/2]:
                assert 0 <= b['targetX']+dx*math.cos(angle)-dy*math.sin(angle) <= w
                assert 0 <= b['targetY']+dx*math.sin(angle)+dy*math.cos(angle) <= h
    print(f"{path.name}: {len(ids)} mảnh, {len(crates)} thùng, hợp lệ")
with wave.open(str(root/'audio'/'snap.wav')) as sound:
    assert sound.getnframes()>0 and sound.getnchannels()==1
print('Âm thanh PCM hợp lệ')
