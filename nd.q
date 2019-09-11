\d .ND

pi:3.14159265358979323846;
mu:0.0;
sigma: 1.0;
pdf:{[x]
	exp[(-1*xexp[x-mu;2])%(xexp[sigma;2]*2)]%(sigma*sqrt[2*pi]);
	}
cdf:{[x]
	ninf:mu-10*sigma;
	sumX:0;
	n:1e5;
	c:(x-ninf)%n;
	k:1;
	while[k<(n-1);
		sumX:sumX+pdf[ninf+k*c];
		k:k+1;
	]
	:c*((pdf[x]+pdf[ninf])%2+sumX);
	}
