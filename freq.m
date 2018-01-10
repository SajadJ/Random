function freq(E,dt,plt)
[nx ny] = size(E);

if dt > 0.0001 % check to see if time is in ns
    f_samp = 1 / ( dt * 10^6 );%(10^6) makes it in MHz
else 
    f_samp= 1 / dt;
end

bin_vals = [0 : nx-1];

f_Hz = bin_vals * f_samp / nx;
Ef = fft(E);


if plt == 'plot'
    figure
    plot(f_Hz/10^9,abs(Ef),'Color',[0.5 0.5 0.5]); 
    xlim ([0 f_samp/(4*10^9)])
    grid on
    title('Frequency content')
    xlabel('Frequency (GHz)') 
    ylabel('Amplitude')
end