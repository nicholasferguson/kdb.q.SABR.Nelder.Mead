# This ports over a C++ version in this github. 
	+ See github.com/nicholasferguson/SABR.NelderMead_Studies_2
	+ This is a first draft.  KDB/q code was not fully optimized so that it could be easily compared to C++.
	+ SABR. This study illustrates how SABR, alpha beta rho nu, is solved using NelderMead 
	+ This was a test case to work with SABR and NelderMead, in KDB+/q
	+ KDB/q version was 64x, downloaded for free from kx.com.  
	+ On windows 10, for quickest results, install q in c:\q and add an env variable QHOME=c:\q

# It has two SABR related computations in function: 
	+ 'Obloj2008'  Method in Obloj 2008
	+ 'hagan2002'  Original Hagan's method in Hagan et. al. 2002
	+ See SABR_main.q and comment out model:`hagan2002 or model:`Obloj2008

# Original VB code and spreadsheet by Changwei Xiong. 
	+ http://www.cs.utah.edu/~cxiong/
	+ Code is based on worksheet SABR(Implied Alpha) in github directory:
	+ references/05.Swaption_Volatility_SABR_Calibration.xls
	+ referneces/05.Changwei_Xiong_SABR_Calibration.pdf
	
# To run: 
	+ q)\cd \<SABR Dir>
	+ q)\l SABR_main.q
	+ Note: This script was run in kdb+ 64x, cmd line:  q q.k -s 1 -p 5010

# Directory structure
	\q
	+ \\\<SABR Dir >
		+ \data

# Quick Summary of Algorithm

+ For each expiry row
	+ MyFunction(SolveMinimum(initguess),true)
		+ initguess has initial values ( per row ) for alpha, beta, rho and nu
		+ SolveMinimum is a NelderMead solver for alpha beta rho and nu.
		+ This Nelder Mead objective function is MyFunction.  
		+ When Nelder Mead converges is reached, it returns	
		+ Then SolveMinimum passes arguments  to MyFunction, for a final pass through.
		+ MyFunction, with its SABR math, calculates a Model Vol.
		
+ Nelder Mead Algorithm	
		+ TBD
		
+ SABR Math
		+ TBD
