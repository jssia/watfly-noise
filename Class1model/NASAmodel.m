clear all; close all; clc;

% Jin Sing Sia (jssia@uwaterloo.ca), 2018/12/03
% Based on code by Khaled Younes

% -- SOURCE --:
% See NASA Technical Report 32-1462: "A Review of Aerodynamic Noise
% From Propellers, Rotors, and Lift Fans", J. E. Marte & D. W. Kurtz

% This code is built based on procedure for estimating far-field
% propeller noise (Appendix B, Section C).

% -- PARAMETERS --:
% shp: Shaft horsepower [hp]
% NB: Number of blades
% D: Propeller diameter [ft]
% r: Observer distance from propeller center [ft]

function SPL = getNoise(shp, B, D, RPM, r, verbose = false, warn = false)
	SPL = 0;

	% Define speed of sound [ft/s]
	c = 1125;

	% Distance from radial reference point to prop disc [ft]
	Z = 1;

	% Calculate reference level L1 (digitization of Fig. B-2)
	L1 = @(shp) 14.26810079692784 * log10(shp) + 86.48677507603948;

	% Calculate correction for speed & radial distance (digitization
	% of Fig. B-3)
	M02Corr = @(D) -28.2877717195795 * log10(Z / D) - 33.2806551613034;
	M04Corr = @(D) -24.1123259543827 * log10(Z / D) - 25.7074661607536;
	M06Corr = @(D) -20.1299897418308 * log10(Z / D) - 19.2533767796971;
	M07Corr = @(D) -16.5346110860105 * log10(Z / D) - 14.5166813307017;
	M08Corr = @(D) -14.8313740451948 * log10(Z / D) - 11.0934655952182;
	M09Corr = @(D) -11.4760494792536 * log10(Z / D) - 6.31497807508983;
	M10Corr = @(D) -8.98387974630316 * log10(Z / D) - 2.70410551554186;

	% Tip Mach number
	Mt = (pi * D * RPM / 60) / c;

	% Transonic regime warning
	if warn && Mt > 0.8
		disp("WARNING: Blade tip is transonic, RPM reduction recommended.");
	end

	% Step 1: Partial SPL based on power input
	powerNoise = L1(shp);

	% Step 2: Correction for blade number
	bladeCorr = 20 * log10(4 / B);

	% Step 2: Correction for prop diameter
	diamCorr = 40 * log10(15.5 / D);

	% Step 3: Correction factor for Mt and D
	% Shortcut to avoid linear interpolation...
	if Mt <= 0.3
		MCorr = M02Corr(D);
	elseif Mt <= 0.5
		MCorr = M04Corr(D);
	elseif Mt <= 0.65
		MCorr = M06Corr(D);
	elseif Mt <= 0.75
		MCorr = M07Corr(D);
	elseif Mt <= 0.85
		MCorr = M08Corr(D);
	elseif Mt <= 0.95
		MCorr = M09Corr(D);
	else
		MCorr = M10Corr(D);
	end

	% Step 4: Correction for directivity - ignored

	% Step 5: Correction for distance attenuation
	distCorr = -20 * log10(r - 1);

	% Step 6: Calculate overall SPL
	SPL = powerNoise + bladeCorr + diamCorr + MCorr + distCorr;

	% Step 7: Harmonic distribution - ignored

	% Step 8: Octave band levels - ignored

	% Step 9: Atmospheric molecular absorbtion - ignored

	% If verbose: Show each calculation
	if verbose
		disp(["Mt = " mat2str(Mt)]);
		disp(["L1 = " mat2str(powerNoise) " dB"]);
		disp(["blade corr. = " mat2str(bladeCorr) " dB"]);
		disp(["diameter corr. = " mat2str(diamCorr) " dB"]);
		disp(["tip mach corr. = " mat2str(MCorr) " dB"]);
		disp(["distance corr. = " mat2str(distCorr) " dB"]);
		disp(["OASPL = " mat2str(SPL) " dB"]);
	end
end

% Worked example test
getNoise(300, 3, 9, 1584, 1000, true);

% Expected output
% Mt = 0.66
% L1 = 121 dB
% blade corr. = 2.5 dB
% diameter corr. = 9.5 dB
% distance corr. = -59.2 dB
% tip mach corr. = -1.0 dB
% OASPL = 72.8 dB

% Discrepancies:
% L1: Probably interpolation error
% distance corr.: Worked example probably used slide rules
% tip mach corr.: Probably interpolation error