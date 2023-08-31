
function [surf_lap,G,H] = surfaceLaplacianFilter(data,x,y,z)

numberOfElectrodes = length(x);


% Initialize empty G, H and cosine distance matrices
G=zeros(numberOfElectrodes);
H=zeros(numberOfElectrodes);
cosdist=zeros(numberOfElectrodes);

%initialize default order and smoothness
order = 12;
smoothness = 3;

% if number of electrodes are less than 100, provides different parameters
% of order and smoothness
if numberOfElectrodes<100
    m=4; order=10;
end



% convert (x,y,z) coordinates of each electrode in spherical coordinates
[azimuth,elevation,r] = cart2sph(x,y,z);
%normalization
maxrad = max(r);
x = x./maxrad;
y = y./maxrad;
z = z./maxrad;

%compute cosine distance between each pair (i,j) of electrodes
for i=1:numberOfElectrodes
    for j=i+1:numberOfElectrodes
        cosdist(i,j) = 1 - (( (x(i)-x(j))^2 + (y(i)-y(j))^2 + (z(i)-z(j))^2 ) / 2 );
    end
end
cosdist = cosdist+cosdist' + eye(numberOfElectrodes);


% compute Legendre polynomial
legpoly = zeros(order,numberOfElectrodes,numberOfElectrodes);
for ni=1:order
    temp = legendre(ni,cosdist);
    legpoly(ni,:,:) = temp(1,:,:);
end

% precompute G and H elements
GH_numerator  = 2*(1:order)+1;
G_denominator = ((1:order).*((1:order)+1)).^m;
H_denominator = ((1:order).*((1:order)+1)).^(m-1);

for i=1:numberOfElectrodes
    for j=i:numberOfElectrodes
        
        g=0; h=0;
        
        for n=1:order
            % compute G and H terms
            g = g + (GH_numerator(n)*legpoly(n,i,j)) / G_denominator(n);
            h = h - (GH_numerator(n)*legpoly(n,i,j)) / H_denominator(n);
        end
        G(i,j) =  g/(4*pi);
        H(i,j) = -h/(4*pi);
    end
end

% mirror matrix
G=G+G'; H=H+H';

% correct for diagonal-double
G = G-eye(numberOfElectrodes)*G(1)/2;
H = H-eye(numberOfElectrodes)*H(1)/2;

%% compute laplacian

% reshape data to electrodes X time/trials
orig_data_size = squeeze(size(data));
if any(orig_data_size==1)
    data=data(:);
else
    data = reshape(data,orig_data_size(1),prod(orig_data_size(2:end)));
end


% add smoothing constant to diagonal 
Gs = G + eye(numberOfElectrodes)*smoothing;

% compute C matrix
GsinvS = sum(inv(Gs));
dataGs = data'/Gs;
C      = dataGs - (sum(dataGs,2)/sum(GsinvS))*GsinvS;

% compute surface Laplacian (and reshape to original data size)
surf_lap = reshape((C*H')',orig_data_size);

