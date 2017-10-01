A demo: application of Gibbs sampling based MRF on image denoising task. 

version 1:   only update weight once.

version 2:   update weight every m*n iterations & optimal lambda & ...

Run demo.m: compare the peroformance between weight-scan, systematic scan and random scan. By adjusting the sigma in Wgibbs.m, we find that the more sigma is, the better performance weight-scan achieve compared with other two baseline methods.
