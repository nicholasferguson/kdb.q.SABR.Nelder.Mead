
/ cdf:{[x]:1f;}

Black76:{[f;L;T;v;rf;PutCall]
	y:0;
	O:`Put`Call;
	Nd1:0;
	Nd2:0;
	OType:O?PutCall;
	if[2<>OType;
		[ 
		d1:(log(F%K)+((xexp[v;2]%2)*T))%(v*sqrt[T]);
		d2: d1 - (v*sqrt[T]);
		if[0=OType;
				[
			Nd1:cdf[d1];
			Nd2:cdf[d2];
			y:exp[neg rf*T]*((F*Nd1)-(K*Nd2));
				]];
		if[1=OType;
				[
			Nd1:cdf[neg 1*d1];
			Nd2:cdf[neg 1*d2];
			y:exp[neg rf*T]*((K*Nd2)-(F*Nd1));
				]];
		]];
	:y;
	}
diffInPutCallParity:{[C;P;F;K;r;T]
	L:C-P;
	R:(F-K)*exp[neg r*T];
	:L-R;
	}
