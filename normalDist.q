
pi:3.14159265358979323846;

mu:0f;
sigma:0f

normalDist:{[val;mu;sigma]
	ret: xexp[(-1*xexp[val-mu;2]%(2*xexp[sigma;2])) % (sigma*sqrt[2*pi]);
	:ret;
	}
	
pdf:{[x]
	/ Integral from a to x
	ninf: mu - 10 *sigma;
	sum:0f;
	n:1e5;
	c: (val-ninf)%n;
	{sum+:pdf[ninf+k*c]}/[n-1;1];
	ret: c*((pdf[val]+pdf[ninf])% (2+sum));
	:ret;
	}
	
