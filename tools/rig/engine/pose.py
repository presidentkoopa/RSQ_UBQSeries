import sys
# off-hand position in the gun's frame (cm F L U) -> qz_lhand (m), pitch -30 = round along the bore
F,L,U=map(float,sys.argv[1:4]); print(f"{0.25-L/100:.4f} {1.3+U/100:.4f} {-0.3-F/100:.4f} -30 0 0")
