function [] = visualize(imagePath)
theImage = double(imresize(imread(imagePath), 0.3)) / 255;

gammasBelow = log(linspace(exp(1),exp(2.199),4));             % The different gamma values to test out.
gammasAbove = (log(linspace(exp(2.201),exp(3.4),4)));
gammas = [gammasBelow 2.2, gammasAbove];
gammas = [1, 1.5, 2.2, (3.4+2.2)/2 3.4]

X = zeros(size(theImage, 1), size(theImage, 2), 3, size(gammas, 2));
for i = 1:size(gammas, 2)
    g = gammas(i);
    
    theGammaAdjustedImage = theImage .^ (1/2.2);
    theGammaAdjustedImage = theGammaAdjustedImage .^ g;
    
    X(:, :, :, i) = theGammaAdjustedImage;
end

figure();
montage(X, 'Size', [2, 3]);
