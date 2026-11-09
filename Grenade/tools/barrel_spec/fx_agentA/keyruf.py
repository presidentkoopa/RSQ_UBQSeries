import numpy as np
from PIL import Image
a=np.array(Image.open('/home/claude/rsq_ubqseries/design/assets/fx_sheets/fx_sheet_rufaswan_magma.png').convert('RGBA'))
bg=(a[...,:3]==255).all(-1); a[bg,3]=0
Image.fromarray(a).save('/tmp/fx_agentA/ruf_keyed.png')
