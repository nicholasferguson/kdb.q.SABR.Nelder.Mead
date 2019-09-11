
gnm_range_sumxsumy2:{[MktVol;ModelVol;row]
	s:0f;
	i:0;
	vMktVol: value MktVol;
	vModelVol: value ModelVol;
	 while[i < (count vMktVol);
	 	s+:xexp[vModelVol[i] - vMktVol[i];2];
	 	i+:1;
	 	];
	:s
	}
/ Key is expiry, Val is Row 'Market ATM Vol' map[`x]?`30 for type 0h ..KeysRow as empty list had issues

rowX : 0;

MyFunction:{[py;Converged]
	bet	: py[0];
	rho	: py[1];
	nu	: py[2];
	cm_AlphaBetRhoNu[`beta;rowX]:py[0];
	cm_AlphaBetRhoNu[`rho;rowX]:py[1];
	cm_AlphaBetRhoNu[`nu;rowX]:py[2];
	Fwd : cm_FixedRates[`FRate;rowX]%100;
    error: 0f;
	y:0f;
	tau: cm_Expiry[`Exp_yrs;rowX]; / 5
	Expiry: ATMmktVolKeys[`Expiry;rowX];
	Tenor: ATMmktVolKeys[`Tenor;rowX];
	atmRow: (exec index from ATMmktVolKeysRow where ATMVolExp=Expiry);
	atmCol: (exec index from ATMmktVolKeysCol where k=Tenor);
	atmfield:(cols cm_ATMmktVol)[atmCol];	
	atm: cm_ATMmktVol[atmfield;atmRow[0]]%100;	
	a0:0f;
	a0:AlphaInitial[Fwd;tau;atm;bet;rho;nu];
	cm_AlphaBetRhoNu[`alpha;rowX]:a0;
	it:0;
	ks:(cols cm_StrikeRates_K);
	while[it < (count cm_MktVol);
		[
		itC:ks[it];
		strikeRates:cm_StrikeRates_K[itC;rowX]%100;
		vol:SABR_BlackVol_InitialAlpha[Fwd;strikeRates;tau;a0;bet;rho;nu;model];
		cm_ModelVol[itC;rowX]:vol;
		it+:1;
		]];

	 MktVol:exec from (flip cm_MktVol) where i = rowX;
	 ModelVol:exec from (flip cm_ModelVol) where i = rowX; 
	 MktVol: {x%100} each MktVol;
	 y:gnm_range_sumxsumy2[MktVol;ModelVol;rowX];
	 / Impose the constraint that - 1 <= rho <= +1 and that nu>0
	 B1:abs[rho] > 1;
	 B2:nu < 0;
	 if[1b in B1,B2;
		y:1e100;]
	 if[Converged=1b;
		[
			rowX+:1;
		]];
	:y;
	}	
