# This ports over a C++ version in this github.
github.com/nicholasferguson/SABR.NelderMead_Studies_2

# SABR. This study illustrates how SABR, alpha beta rho nu, is solved using NelderMead 
# This was a test case to work with SABR and NelderMead, in KDB+/q

+ It has two SABR related computations in function: 
	+ 'Obloj2008'  Method in Obloj 2008
	+ 'hagan2002'  Original Hagan's method in Hagan et. al. 2002
+ See SABR_main.q and comment out model:`hagan2002 or model:`Obloj2008
+ This SABR model does an initial fit of beta rho nu using method of a local calibration algorithm.  

# Original VB code and spreadsheet by Changwei Xiong. 
+ http://www.cs.utah.edu/~cxiong/

+ Note: This script was run in kdb+ 64x, cmd line:  q q.k -s 1 -p 5010
	
# To run: 
+ q)\cd \<SABR Dir>
+ q)\l SABR_main.q

# Directory structure
\q
+	\\\<SABR Dir >
+	   \data

