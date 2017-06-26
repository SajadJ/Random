function [S,freq] = stransform(x,t,fmin,fmax,n);
%
% STRANSFORM Syntax:  [S,f] = stransform(x,t,fmin,fmax,n)
%
% where:  S = output time frequency representation
%         f = output frequency vector (MHz)
%         x = signal to be analyzed
%         t = time vector (ns)
%         fmin = minimum frequency to analyze in MHz (must be positive)
%         fmax = maximum frequency to analyze in MHz (must be <= Nyquist)
%         n = number of points to use for fft
%
% This function computes the S-transform time-frequency representation of a GPR signal,
% which is a hybrid STFT/WT, using the fast frequency domain algorithm provided in 
% Stockwell et al. (1996).
%
% by James Irving
% June, 2001
%
% modified for GPR units ns in time; MHz in frequency
% SK


% compute some initial parameters
nppt = length(t);  % number of points per trace
si = t(2)-t(1) ;    % sampling interval (s)
fn = 1/(2*si)*1000;    % Nyquist frequency (Hz)
df = 2*fn/n;       % sampling interval in frequency domain (Hz)
f = -fn:df:fn-df;  % frequency vector (Hz) for FFT stuff
w = 2*pi*f;        % frequency vector (rad/s) for FFT stuff
f2 = 0:df:fn;      % frequency vector (Hz) for computing S-transform frequencies
w2 = 2*pi*f2;      % frequency vector (rad/s) for computing S-transform frequencies
% fmin = fmin/1e3;                   % minimum analysis frequency (Hz)
% fmax = fmax/1e3;                   % maximum analysis frequency (Hz)
[temp,jmin] = min(abs(f2-fmin));   % closest index of min. frequency in f2
[temp,jmax] = min(abs(f2-fmax));   % closest index of max. frequency in f2

X = fftshift(fft(x,n));            % Fourier transform input trace
X = [X,X];                         % double to handle wrap around
jmin;
jmax;
for j=jmin:jmax                    % perform S-transform
   if j==1 
      S(1,:) = mean(x)*ones(size(x));  % set DC value of transform to average of signal
   else 
      G = exp(-2*pi^2*w2(j)^-2.*w.^2); % Gaussian window
      H = X(j:j+n-1);                  % shifted Fourier spectrum
      B = H.*G;                        % fft of S-transform for frequency f2(j)
      temp = ifft(fftshift(B));        % transform to time
   	  S(j-jmin+1,:) = temp(1:nppt);    % place in matrix S
   end
end
S=abs(S);
freq = ( f2(jmin:jmax)) ;          % output frequency vector (MHz)

% %normalize transformed amplitudes
% [nrows ncols]=size(S);
% Smax=max(S);
% s=zeros(size(S));
% for i=1:ncols
%     s(:,i)=S(:,i)/Smax(i);
% end


% ylim([100 300]);
% figure;
% surf(t, freq, s); view (20, 80);
% shading interp;
% axis xy; 
% colormap(jet);
