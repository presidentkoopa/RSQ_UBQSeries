// RS VR fists (1.5): BD22's own punch MOTION, moved onto Ermac's fist. Generated from BD22's
// fistclosed.md3 (its one fist surface, rigidly fitted frame by frame against its ready frame,
// residual under 0.05 cm) and converted to a ModifyBobLayer3D turn (yaw, pitch, roll) and move
// for hand.md3, checked against the render chain (hudrender.to_local) to 0.001 cm. So when BD22
// throws a jab, cross or uppercut, our fist travels exactly the path BD's glove did.
class RSQ_FistMoves abstract
{

	// per fistclosed.md3 frame 0..29: turn (yaw, pitch, roll) and move
	clearscope static Vector3, Vector3 Move(int f)
	{
		static const double ty[] = { -0, -0, -0, 0, 1.04, 3.51, 6.46, 8.93, 7.35, -0, -10.72, -20.65, -25.02, -12.33, -10.86, -8.71, -0, -0, -0.01, -0.01, 0, 0.01, -0, -27.6, -0, -4.88, -7.84, -9.37, -9.93, -10.01 };
		static const double tp[] = { -0, -0, -0, -0, 0, 0, -0, -0, -0, -0, 0, 0, 0, -21.14, -1.32, 27.36, 65.02, 65.02, 65.02, 65.02, 65.01, 65.01, 65.01, 44.31, -0, 0, 0, 0, 0, 0 };
		static const double tr[] = { -0, 0, 0, 0, -0, 0, 0.01, 0.01, 0.01, -0, -0, -0.01, -0, 74.11, 81.71, 85.31, 94.99, 94.99, 94.99, 94.99, 95, 95, 95, 14.01, -0, -0, -0, 0, -0, -0 };
		static const double mx[] = { -0, 0, -0, 0, -0.11, -0.73, -2.12, -3.82, -2.35, -0, 1.8, 3.42, 4.1, -5.51, 3.25, 9.56, 1.4, -0.25, -2.34, -4.54, -6.52, -7.95, -8.5, 2.78, -0, 2.04, 3.27, 3.9, 4.13, 4.16 };
		static const double my[] = { 0, -0, 0, 0, -0, -0, 0, 0, 0, 0, -0, 0, 0, -1.13, 4, 4.88, 2.04, 2.18, 2.37, 2.56, 2.73, 2.85, 2.9, -2.28, 0, -0, 0, -0, 0, 0 };
		static const double mz[] = { 0, 4.5, -7.95, -20.4, -17.97, -12.18, -5.34, 0.29, -5.78, -14.28, -14.45, -14.9, -15.19, 0.84, -2.95, -14.88, -27.71, -24.79, -20.71, -16.23, -12.11, -9.08, -7.9, -10.98, 0, -0.09, -0.22, -0.32, -0.36, -0.36 };
		if (f <= 0 || f >= mx.Size())
			return (0, 0, 0), (0, 0, 0);
		return (ty[f], tp[f], tr[f]), (mx[f], my[f], mz[f]);
	}

	// family: 1 ONG, 2 UNG, 3 UNS, 0 a still fist
	clearscope static int MeshFrame(int family, int frame)
	{
		// sprite frame letter (A = 0 ...) -> fistclosed frame, per family (MODELDEF.bd.txt)
		static const int ong[] = { 0, 1, 2, 3, 4, 5, 7, 8, 0, 0, 9, 10, 11, 12, 12, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0 };	// ?ONG, PONG: jab, cross, hook
		static const int ung[] = { 1, 8, 9, 10, 11, 12, 12, 12, 12, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 0, 0, 0, 0, 0, 0, 0 };	// ?UNG, PUNG: uppercut
		static const int uns[] = { 23, 24, 25, 26, 27, 28, 29, 0, 25, 26, 27, 28, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };	// PUNS
		if (frame < 0 || frame >= ong.Size())
			return 0;
		if (family == 1) return ong[frame];
		if (family == 2) return ung[frame];
		if (family == 3) return uns[frame];
		return 0;
	}
}
