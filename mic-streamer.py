import os
import sys
import time
from subprocess import call

ARECORD_DEVICE = os.environ['ARECORD_DEVICE']
RECEIVER_URL = os.environ['RECEIVER_URL']

def debug(s):
  #print(s)
  #sys.stdout.flush()
  pass

COMMAND = ('arecord --device=hw:%s --format S16_LE --rate 32000 -c1 -V mono | ffmpeg -i - -acodec libmp3lame -ab 32k -ac 1 -f mpegts %s' %  (ARECORD_DEVICE, RECEIVER_URL))
debug('COMMAND="' + COMMAND + '"')

print('Starting audio stream now.\n')
sys.stdout.flush()
while True:
  call([COMMAND], shell=True)
  print('\n\n\nERROR: Audio streaming failed. Will retry in 10 seconds..')
  sys.stdout.flush()
  time.sleep(10)
  print('Retrying audio stream now.\n')

