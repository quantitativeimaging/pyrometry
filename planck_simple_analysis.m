%% Planck Equation manipulation for estimating temperature
% Using 'hard' cut on / off properties for colour filters...

h = 6.63E-34;
c = 3E8;
kb = 8.31/6.022E23;
listTs = 800:25:1600;

listRG_ratios = zeros(size(listTs));

lambda_red_lower = 610E-9;
lambda_red_upper = 680E-9;
QE_red = 0.07;

lambda_grn_lower = 500E-9;
lambda_grn_upper = 580E-9;
QE_grn = 0.50;

for lp = 1:length(listTs);

T = listTs(lp);

lambdas = 400E-9:1E-9:2500E-9;

% For a black body - Watts per steradian per metre cubed
Bl = (2*h*c^2)./(lambdas.^5)./( exp( h*c./(lambdas.*kb.*T) ) -1 );

% convert to photons emitted per m^2 per steradian, per m of wavelength
photons = 1E-9*Bl./(h*c./lambdas);

figure(10)
plot(lambdas, photons)

signal_red = QE_red*sum(photons( (lambdas > lambda_red_lower) & (lambdas < lambda_red_upper)));
signal_grn = QE_grn*sum(photons( (lambdas > lambda_grn_lower) & (lambdas < lambda_grn_upper)));

ratio_RG_theory = signal_red./signal_grn;
listRG_ratios(lp) = ratio_RG_theory;

end

figure(11)
plot(listTs, listRG_ratios)
 set(gcf,'color','w')
 set(gca, 'fontSize', 18)
xlabel('Temperature')
ylabel('Ratio')
title('Estimated red/green signal ratio from Planck')

coeffs = polyfit(listTs(( listRG_ratios<1.5 & listRG_ratios>1 )), ...
	               listRG_ratios( listRG_ratios<1.5 & listRG_ratios>1 ), 1);

T_fitting = 1000:100:1500;
ratio_fitted = polyval(coeffs, T_fitting);

figure(11)
hold on
 plot(T_fitting , ratio_fitted)
hold off
legend('Planck', 'Fit in relevant T-range')

slope = coeffs(1)
intercept = coeffs(2)

ratio_in_picture = 1.35

Temp_in_recon = (ratio_in_picture-intercept) ./ slope