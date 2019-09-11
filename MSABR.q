/ The SABR model has two variables, the forward asset price F˜ (T), and the local volatiliity A˜(T).
/  rho controls the skew of the curve rho is p (correlation)
/      rho is dW due to stochastic alpha in Forward and vol formula.
/  Beta is rate of Forward
/  nu vol of vol 
/  alpha  (stochastic alpha) 
/  alphas are linked to ATM vols while rhos are linked to skew
 
sgn:{[num]
	if[num>0;:1];
	if[num=0;:0];
	:neg 1;
	}
norm:{[a;b;c;d]
	: sqrt[xexp[a;2]+xexp[b;2]+xexp[c;2]+xexp[d;2]]
	}

Chi:{[z;rho]
	t1:sqrt[(1-(2*rho*z))+xexp[z;2]]+z-rho;
	t2:t1 % (1 - rho);
	ret: log[t2];
	:ret;
	}
CubicRoot:{[x]
	:xexp[abs[x];.333333333333333333]*sgn(x);
	 }
QuadraticSolver:{[a;b;c]
	q: (-0.5*(b+sgn[b]*sqrt[xexp[b;2]-(4*a*c)]))[0]; / nick...why?
	x1:q%a;	
	x2:c[0]%q;
	if[(x1*x2)<0;	
		:max x1,x2;
		];
	if[x1>0;
		:min x1,x2;
		]
	:-1;
	}
CubicSolver:{[a;b;c;d]
	root:();
	b: b%a;
	c: c%a;
	d: d%a;
	p:c-xexp[b;2.0]%3.0;
	/ following at times is a list and an atom?
	q1: (((b*(2.0*xexp[b;2.0]) - (9.0 *c)) % 27.0) + d),();
	q:q1[0];
	deg:2.09439510239319;  / PI*2%3
	tol1:0.00001;
	tol2:1e-20;
	z:();
	nr:0j;
	t1:0f;
	t2:0f;
	ratio:0f;
	g:0;
	if[sqrt[(xexp[p;2]+xexp[q;2])] < tol2;
	 	nr:3;z:nr#(); ];
	if[sqrt[xexp[p;2]+xexp[q;2]] >= tol2;
		[
		g: xexp[(p%3);3]+xexp[(q%2);2];
		if[g > 0;
			[
			t1:neg q%2;
			t2:sqrt[g];
			ratio:1;
			if[q<>0;
				ratio:t2%t1;
			]
			if[abs[ratio] < tol1;
				nr:3;
				z,:2*CubicRoot[t1];
				z,:CubicRoot[neg t1];
				z,:z[1];];
			if[abs[ratio] >= tol1;
				nr:1;
				z,:CubicRoot[t1+t2]+CubicRoot[t1-t2];;
			]
		  ]];
		if[g <= 0;
		  [
			nr:3;
			ad3:p%3;	
			e0:2f*sqrt[neg ad3];
			phi: (neg q) % (2f * sqrt[xexp[neg ad3;3]]);
			phi3: cos[phi]%3f;
			z,:e0*cos[phi3],e0*cos[phi3+deg],e0*cos[phi3-deg];
			]];
		]];
	it:0;
	while[it < nr;root,:z[it] - (b%3);it+:1;];
	/ nick
	:root[0]%1f;
	}
AlphaInitial:{[fwd;tau;atm;bet;rho;nu]
	h:1-bet;
	ret:0f;
	a: (((xexp[h;2]*tau)%24)%xexp[fwd;2*h]);
	b:(((rho*bet*nu*tau)%4)%xexp[fwd;h]);
	c:1+((2-3*xexp[rho;2])*xexp[nu;2]*tau)%24;
	d: (neg atm) * xexp[fwd;h];
	param_norm: norm[a;b;c;d];
	if[abs[(norm[0;0;c;d] % param_norm) - 1][0] <eps;
			ret: neg d % c; ] 
	$[abs[(norm[0;b;c;d] % param_norm) - 1][0] <eps;
			[
			ret: QuadraticSolver[b;c;d];
			];
			[
			ret: CubicSolver[a;b;c;d];
			]
	 ];
	:ret;	
	}
GetAlpha:{[f;t;atm;b;r;v]
	d:1-b;
	oo:xexp[d;2]*t%(24*xexp[f;2*d]);
	pp:r*b*v*t%(4*xexp[f;d]);
	qq:(1+(2-(3*xexp[r;2])))%(24*xexp[v;2]*t);
	rr:-1* atm*xexp[f;d];
	: CubicSolver[oo;pp;qq;rr];
	}
SABR_Vol_By_ATM:{[f;x;t;atm;b;r;v]
	:SABR_Vol[f;x;t;GetAlpha[f;t;atm;b;r;v];b;r;v];
	}
SABR_Vol:{[f;x;t;a;b;r;v]
	d:1-b;
	p:f*x;
	d:1-b;
	p:f*x;
	num: 1+
	(t*
	(
	(((xexp[d;2]%24)*xexp[a;2])%xexp[p;2*d])
	+
	(0.25*r*b*v*a%xexp[f;d])
	+ ((2-(3*xexp[r;2]))*xexp[v;2]%24)
	)
	);
	if[abs[(f-x)%f]<0.0000000001;
		: (a*num)%xexp[f;d];
	]
	q:log[f%x];
	z:(v%a)*xexp[p;d%2]*q;
	chi:log[((xexp[((1-(2*r*z))+xexp[z;2]);.5]+z)-r) %(1-r)];
	den:chi * xexp[p;d%2] * (1+(((xexp[d;2]%24)*xexp[q;2]))+((xexp[d;4]%1920)*xexp[q;4]));
	: (z*a*num)%den;
	}
SABR_BlackVol_InitialAlpha:{[fwd;k;tau;a0;bet;rho;nu;model]
	$[model=`Obloj2008;model:`Obloj2008;model:`hagan2002];
	h:1-bet;
	p:xexp[(fwd*k);(h%2)];
	q:log[fwd%k];
	v:((xexp[h;2]*xexp[a0;2])%(24*xexp[p;2]))+((rho*bet*nu*a0)%(4*p)) +((2-3*xexp[rho;2])*(xexp[nu;2]%24));
	zeta:0f;
	zeta_chi:0f;
	eta:0f;
	decision:0;
	if[abs[q]<eps;
		[
		eta:p;
		zeta_chi:1;
		decision:1;
		]];
	if[abs[h] < eps;
		[
		eta:1;
		zeta:(nu%a0)*q;
		zeta_chi:zeta%Chi[zeta;rho];
		decision:1;
		]];
	if[decision=0;
		[
		eta: (xexp[fwd;h] - xexp[k;h])%(h*q);
		if[model = `hagan2002;
			zeta: (nu%a0)*p*q;
			];
		if[model = `Obloj2008;
			[
				zeta: (nu%a0)*eta*q;
			]];			
		zeta_chi: zeta % Chi[zeta;rho];
		]];
	ret:zeta_chi * (a0*(1+(v*tau))) %eta;
	:ret;
	}
