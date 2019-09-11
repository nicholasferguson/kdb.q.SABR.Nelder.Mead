\l data\data.q
\l Black76.q
\l MSABR.q
\l nm.q
\l nd.q
\l myFunction.q

/ model:`hagan2002;
model:`Obloj2008;

	ATMmktVolKeys:flip select `$-1_ ' string Expiry, `$-1_ ' string Tenor from MktVolSmiles;
	ATMmktVolKeysCol: flip (`k`index!((`$-1_ 'x:1_ ' x:1_ string cols MktATMVol) ;til (-1+count cols MktATMVol)));
	ATMmktVolKeysRow:select ATMVolExp:`$1_ ' x:-1_ ' string ATMVolExp, index:i from MktATMVol;
	cm_FixedRates:flip select FRate from DerivedSwapRate;
	col_FixedRates:`Fixed;
	cm_MktVol: flip select kneg200,kneg100,kneg50,kneg25,k0,k25,k50,k100,k200  from MktImplSwaptionVol;
	cm_ModelVol: flip select kneg200,kneg100,kneg50,kneg25,k0,k25,k50,k100,k200  from MktImplSwaptionVol;
	cm_Expiry:flip select Exp_yrs from MktImplSwaptionVol;
	cm_StrikeRates_K: flip select kneg200,kneg100,kneg50,kneg25,k0,k25,k50,k100,k200 from StrikeRates;
	cm_ATMmktVol:flip select t1y,t2y,t3y,t4y,t5y,t7y,t10y,t20y,t30y from MktATMVol;
	/ initLocalCalibration
	cm_AlphaBetRhoNu: flip SABR_params;
	/ AddSingleConstraint[-1; "="; 0];
	AddSingleConstraint[1; "<="; 1];
	AddSingleConstraint[0;"<";1];
	AddSingleConstraint[0; ">"; -1];
	AddSingleConstraint[1; ">="; -1];
	AddSingleConstraint[2; ">="; -1];
	AddSingleConstraint[2; "=>"; -1];
	SetFunctionName[`MyFunction];
	row:0;
	tRow: count SABR_params;
	/ main while loop
	{initguess: raze value exec beta, rho, nu from (flip cm_AlphaBetRhoNu) where i = row;
	 rem:MyFunction[SolveMinimum[initguess];1b];}/[tRow;row]
	
	 -1"================= SABR Model Output: Alpha Beta Rho Nu (via NelderMead's RunFunction/MyFunction)===========";
	 cm_AlphaBetRhoNu: flip cm_AlphaBetRhoNu;
	 show cm_AlphaBetRhoNu;
	
	 -1"================= SABR Model Output: SABR volatilities  (via NelderMead's RunFunction/MyFunction)  ===========";
	 cm_ModelVol: flip cm_ModelVol;
	 show cm_ModelVol;
	 cm_MktVol: flip cm_MktVol;