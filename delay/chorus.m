function y = chorus(x, delay_time, lfo_params, fs)
%
% A simple chorus effect
% 
% - x: input signal
% - delay_time (in second): delay time for the variable tap
% - lfo_params: 
%   - lfo_params.depth (time): control the excursion of modulation
%   - lfo_params.rate  (Hz): control the rate of modulation
% - fs: sampling rate
%
% Version 0.1, May-16-2015 
%
% By Juhan Nam, KAIST

y = zeros(length(x),1);	

% length of delayline
MAX_DELAY_LENGTH = 44100*2;

% write pointer
wp = 1;

% length of delayline
delay_length = delay_time*fs;

% fill delayline with random noise
delayline = zeros(MAX_DELAY_LENGTH,1);

lfo_depth = lfo_params.depth*fs;
lfo_phase = 0;
lfo_phase_inc  = 2*pi*lfo_params.rate/fs;

% feed-back loop
for n=1:length(x)
    
    % LFO
    lfo_phase = lfo_phase + lfo_phase_inc;
    if lfo_phase > 2*pi
        lfo_phase = lfo_phase - 2*pi;
    end
    lfo_out = lfo_depth*sin(lfo_phase);

    % read sample
    op = wp - delay_length;
    op = op + lfo_out;
    if ( op < 1 )
        op = op + MAX_DELAY_LENGTH;
    end
    rp = floor(op);
    rp_frac = op - rp;
    
    % read sample using linear intepolation
    if (rp == MAX_DELAY_LENGTH) | (rp == 0)
        tap_out = (1-rp_frac)*delayline(MAX_DELAY_LENGTH) + rp_frac*delayline(1);
    else
        tap_out = (1-rp_frac)*delayline(rp) + rp_frac*delayline(rp+1);
    end
    
    % write output
    delayline(wp) = x(n);
    
    % update write pointer
    wp = wp + 1;
    if wp > MAX_DELAY_LENGTH
        wp = 1;
    end
    
    y(n) = tap_out;
end



