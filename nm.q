ConItem:([]index:();coef:();dirX:();bound:();n:());
constraint:([]index:();coef:();dirX:();bound:());
Apex:([]x0:();x1:();x2:();f:`float$();typeX:`int$();id:`int$())
Apex,:(3.0f;0.3f;0.3f;0.3f;0;0i)
simplex_types:([]es:`xoc`xic`c`r`e;ed:(1 2 3 4 5))
simplexT:4#Apex;
functionName:`MyFunction;
/ functionName:`none;   / should lambda be a string or a symbol

simplex: simplexT;

/ sel:{$[`~y;x;select from x where sym in y ]}

code_syms:([]code:(`eq; `gt; `gteq; `eqgt; `lt; `lteq; `eqlt);sym:("=";">";">=";"=>";"<";"<=";"=<");cases:( 0; 1; 1;1; -1; -1; -1));

/ size:8;
cnt:0j;
PWEIGHT: 1e30;
CONTOLERANCE:1e-3;
ConArray:([]index:`long$();coef:`long$();dirX:`long$();bound:`long$();n:`long$());
pv:();
/ round:0;
alpha: 1.0;  /  reflection
gamma: 2.0;  /  expansion
rho: 0.5;    /  contraction
sigma:0.5;   /  shrinkage
MAXITER:1000; /  maximal # of iterations
MAXINITIAL:10;
XTOL:0.00001; / simplex size convergence
FTOL:1e-010 ; / function value convergence
eps:1e-020 ; / function value convergence
previousfunctionvalue:0;
penalty:0.0;
sse:0.0;
/ params:10.0 10.0 10.0 ;

AddConstraint:{[index;coef;dirY;bound]
 ConArray,:(index;coef;(?[code_syms;enlist(~\:;`sym;dirY);0b;enlist[`cases]!enlist[`cases]]);bound;1);
	}
CalculatePenalty:{[pv]	
	total:0f;diff:0f;cnt:0;
		while[ cnt < count ConArray;
		[
			c: select from `ConArray where i = cnt;
			val:0f;	k:0;
			while[ k < c[`n][0];
				[
				a:c[`coef][k];a1:c[`index][k];
				a2:pv[a1];
				if[a2 < count pv;val+:value exec val:coef * pv @ index from c where i = k;]
				];
			k+:1;]
		];
			diff: val - c[`bound][0];
			B1:(c[`dirX]) = 0;
			B2:(c[`dirX]*diff) < 0;
			if[1b in B1;  
					if[abs[diff] > CONTOLERANCE;total+:PWEIGHT*(abs[diff]-xexp[CONTOLERANCE;2])]]
			 if[1b in B2;
					total+:PWEIGHT*xexp[diff;2]]
		cnt+:1;
		];
	:total;	
	};
CalculatePenaltyIndex:{[index]	
	total:0f;diff:0f;cnt:0;
	pv:raze value exec  x0,x1,x2 from `simplex where i=index;
	while[ cnt < count ConArray;
		[
			c: select from `ConArray where i = cnt;
			val:0f;	k:0;
			while[ k < c[`n][0];
				[
				a:c[`coef][k];a1:c[`index][k];
				a2:pv[a1];
				if[a2 < count pv;val+:value exec val:coef * pv @ index from c where i = k;]
				];
			k+:1;]
		];
			diff: val - c[`bound][0];
			B1:(c[`dirX]) = 0;
			B2:(c[`dirX]*diff) < 0;
			if[1b in B1;  
					if[abs[diff] > CONTOLERANCE;total+:PWEIGHT*(abs[diff]-xexp[CONTOLERANCE;2])]]
			 if[1b in B2;
					total+:PWEIGHT*xexp[diff;2]]
		cnt+:1;
		];
	:total;	
	};

SetFunctionName:{functionName:x}

	/ SolveMinimum calls CalculateNewApexToReplaceWorstApex or calls GetInitialSimplex
	/ which then calls void ApexEvaluate(Apex* a) which cals RunFunction.
	/ ApexEvaluate is only function that calls RunFunction.
runCount:0;
RunFunction:{[params] 	
	runCout::runCount+1;
	sse:0.1f;
	$[functionName=`none;
			sse:xexp[params[0]-4;2] + xexp[params[1]-2.7;4] * sin[params[1]-2] + xexp[params[2]-6.7;4]* cos[params[2]-6.7];
		sse:MyFunction[params;0b]		
		];
	 :sse;
	}
SetFunctionName:{[x]
	functionName:`x;
	}
AddSingleConstraint:{[index;dirY;bound]
	coef:1;
	tmp:(?[code_syms;enlist(~\:;`sym;dirY);0b;enlist[`cases]!enlist[`cases]]);
	ConArray,:(index;coef;tmp[`cases][0];bound;1);
	}
	/    Nelder-Mead method loops as follows:
	/  
	/    order ascendingly the n apexes by function value (n = dimension + 1, smallest f(x) ==> best)
	/    check convergence (must be under TOL=>diff between best value and others, both for function and parameters)
	/    calculate xo (i.e. the centroid of the apexes excluding the worst apex)
	/    reflextion: xr = xo + alpha * (xo - xn)    
	/    if xr better than x1 then do "expansion":
	/        xe = xo + gamma * (xr - xo)
	/        if f(xe) < f(xr) then xe --> xn otherwise xr --> xn
	/    elseif xr better than x(n-1) then do "reflection":
	/        xr --> xn
	/    elseif xr better than xn then do "outside contraction":
	/        xoc = xo + rho * (xr - xo)
	/        if f(xoc) < f(xr) then xoc --> xn
	/        else do "shrinkage": compute xi = x1 + sigma * (xi - x1) for i = 2 to n
	/    else do "inside contraction":
	/        xic = xo - rho * (xr - xo)   <==> xic = xo + rho * (xn - xo) if alpha = 1 and rho = 1/2
	/        if f(xic) < f(xn) then xic --> xn
	/       else do "shrinkage": compute xi = x1 + sigma * (xi - x1) for i = 2 to n
	/   end if
SimplexGets_XEXR:{[xo;xr;n]
	xe:CalculateNewApexToReplaceWorstApex1[xo; xr;neg gamma];
	xe[`typeX]:5;
	B:xe[`f][0] < xr[`f][0];
	$[1b in B;
		update x0:xe[`x0], x1:xe[`x1],x2:xe[`x2],f:xe[`f],typeX:xe[`typeX] from `simplex where i= (n-1);
	update x0:xr[`x0], x1:xr[`x1],x2:xr[`x2],f:xr[`f],typeX:xr[`typeX] from `simplex where i= (n-1)
	];
	}
SimplexGets_XR:{[xr;n]
	update x0:xr[`x0], x1:xr[`x1],x2:xr[`x2],f:xr[`f],typeX:xr[`typeX] from `simplex where i= (n-1);	
	}
SimplexGets_XOCShrink:{[xr;xo;n]
	xoc:CalculateNewApexToReplaceWorstApex1[xo; xr;neg rho];
	xoc[`typeX]:5;
	B: xoc[`f][0] < xr[`f][0];
		$[1b in B;
			update x0:xoc[`x0], x1:xoc[`x1],x2:xoc[`x2],f:xoc[`f],typeX:xoc[`typeX] from `simplex where i= (n-1);
		Shrink[]					
		  ];
	}

SimplexGets_XICShrink:{[xo;xr;n]  /default
	xic:CalculateNewApexToReplaceWorstApex1[xo;xr;rho];
	xic[`typeX]:2;	
	B:xic[`f][0] < simplex[`f][n-1];
	$[1b in B;
		update x0:xic[`x0], x1:xic[`x1],x2:xic[`x2],f:xic[`f],typeX:xic[`typeX] from `simplex where i= n-1;
	Shrink[]
	];
	}
/ receives a list of 3 floats for beta rho nu. See MyFunction
/ keep solving until objective function 'f' is at a minimum
/ when SolveMinimum exits, it goes to a final MyFunction with Convergence = true
SolveMinimum:{[pvStart]
	n: 1+ count pvStart;
	GetInitialSimplex[pvStart];
	iter:0;
	while[iter<MAXITER;
		[
			`f xasc `simplex;
			if[CheckConvergence[];
				[	
					vv:raze value exec  x0,x1,x2 from `simplex where i=0;
					:vv;			
				]];
		/ n:4;
		xo: GetCentroidExcludingWorstApex[];xo[`typeX]:3;
		xe:Apex;delete from xe;
		xr:CalculateNewApexToReplaceWorstApex[xo;n-1;alpha]; xr[`typeX]:4; 	
		B:xr[`f][0] <  simplex[`f][0];
		B1:xr[`f][0] <   simplex[`f][n-2];
		B2:xr[`f][0] <   simplex[`f][n-1];
		$[1b in B;  / 1
				SimplexGets_XEXR[xo;xr;n];
		 1b in B1;  / 2
				SimplexGets_XR[xr;n];
		 1b in B2;
				SimplexGets_XOCShrink[xr;xo;n];
		SimplexGets_XICShrink[xo;xr;n]
          ];	
		iter+:1;
		]];
	}
/ Compares best against others and updates others with result.
Shrink:{[]
	temp0:select from `simplex where i = 0;
	cnt:1;
	while[ cnt < 4;
	[
		temp1:select from `simplex where i = cnt;
		temp:CalculateNewApexToReplaceWorstApex1[temp0;temp1;neg sigma];
		update x0:temp[`x0], x1:temp[`x1],x2:temp[`x2],f:temp[`f],typeX:temp[`typeX] from `simplex where i= cnt;
		cnt:cnt+1;
	]];
	}
/ receives a list of 3 floats.
GetInitialSimplex:{[pvStart]
	pv:pvStart;
	shift:0;
	n:1+count pv;
	delete from `simplex; / init to empty;
	`simplex insert Apex;`simplex insert Apex;`simplex insert Apex;`simplex insert Apex;
	UpdatePvToSimplex[pv;0];
	Apex_F_Evaluate[0];
	shift:max[1,abs[pv]];
	factor:0f;
	cnt:0j;
	it:1;
	while[it<n;
		UpdatePvToSimplex[pv;it];
		factor:1;
		DOIT:0b;
		LOOP:0;
		pv0:pv;
		while[DOIT=0b;
			pv0[it-1]:pv[it-1]+shift*factor;
			UpdatePvToSimplex[pv0;it];
			factor:factor%2;
			ret:CalculatePenalty[pv0];
			B:eps in max ret, eps;
			B1:LOOP > MAXINITIAL,();
			if[1b in B1;out[2]:3];
			$[1b in B;DOIT:1b;DOIT:0b];
			LOOP+:1;
		]
	    simplex;   / why do I need this?
		Apex_F_Evaluate[it];
		it+:1;
		];

	}

CheckConvergence:{[]
	xdiff:0f;
	fdiff:0f;
	it:1;
	n: count simplex;
	pv0:raze value exec  x0,x1,x2 from `simplex where i=0;
	while[it < n;  / loop over apexs except the 1st.
		j:0;
		pv:raze value exec  x0,x1,x2 from `simplex where i=it;
		while[j < n-1;
			xdiff: max xdiff,(abs[pv[j]-pv0[j]]);
			j+:1;
		];
		it+:1;
		]	
	xdiff=xdiff%(max over pv0,1);
	fdiff:abs[(flip simplex)[`f;n-1]-(flip simplex)[`f;0]]%(max 1, abs[(flip simplex)[`f;0]]);
	/ if[fdiff = 0;:0b];
	B:xdiff < XTOL;
	B1:fdiff < FTOL;
	if[1b in B,B1;
		:1b;
		];
	:0b;

	}

Apex_F_Evaluate:{[simplex_index]
	penalty:CalculatePenaltyIndex[simplex_index];
	B:0 in (min 0, penalty);
	if[B = 1b;
		[
			pv: raze value exec x0, x1, x2 from `simplex where i=simplex_index;
			previousfunctionvalue::RunFunction[pv]; 
		]];
	update f:(previousfunctionvalue+penalty) from `simplex where i=simplex_index;
	}
Apex_F_EvaluateOne:{[apexNew]
	pv:raze value exec  x0,x1,x2 from apexNew;
	penalty:CalculatePenalty[pv];
	B:0 in (min 0, penalty);		
	if[B = 1b;
		[
		previousfunctionvalue:: RunFunction[pv];
		]];
	apexNew[`f]:(previousfunctionvalue+penalty);
	:apexNew;
	}
CalculateApex:{[indexT]
	apex:select [indexT+1] from `simplex;
	:apex; 
	}
/ x's get sample mean.
GetCentroidExcludingWorstApex:{
	centroid:Apex; delete from centroid;
	centroid: flip centroid;
	n: count simplex;
	centroid[`x0]: ((sum simplex[`x0])-simplex[`x0][n-1])% (n-1);
	centroid[`x1]: ((sum simplex[`x1])-simplex[`x1][n-1])% (n-1);	
	centroid[`x2]: ((sum simplex[`x2])-simplex[`x2][n-1])% (n-1);
	:(flip centroid);		
	}
UpdatePvToSimplex:{[pv;it]
	update x0:pv[0], x1:pv[1],x2:pv[2] from `simplex where i= it;
	}
CalculateNewApexToReplaceWorstApex:{[apexA;index;C]
	apexB: select from `simplex where i = index;
	apexNew: Apex; delete from apexNew;
	apexNew[`x0]: apexA[`x0] + C * (apexA[`x0] - apexB[`x0]);
	apexNew[`x1]: apexA[`x1] + C * (apexA[`x1] - apexB[`x1]);
	apexNew[`x2]: apexA[`x2] + C * (apexA[`x2] - apexB[`x2]);		
	apexNew:Apex_F_EvaluateOne[apexNew];
	:apexNew;
	}
CalculateNewApexToReplaceWorstApex1:{[apexA;apexB;C]
	apexNew: Apex; delete from apexNew;
	apexNew[`x0]: apexA[`x0] + (C * (apexA[`x0]) - apexB[`x0]);
	apexNew[`x1]: apexA[`x1] + (C * (apexA[`x1]) - apexB[`x1]);
	apexNew[`x2]: apexA[`x2] + (C * (apexA[`x2]) - apexB[`x2]);	
	apexNew:Apex_F_EvaluateOne[apexNew];
	:apexNew;
	}
printSimplex:{[]
	it:0;
	j:0;
	while[it < (count simplex);
	it+:1;
	]
	}
