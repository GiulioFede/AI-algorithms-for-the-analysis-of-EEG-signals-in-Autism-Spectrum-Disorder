

%{

    La seguente funzione prende in ingresso un segnale (una trial) e
    restituisce il suo spettro (di potenza) calcolato secondo il metodo Welch. Lo
    spettro risultante sarà smussato rispetto allo spettro calcolato
    staticamente e includerà le sue stesse frequenze grazie allo zero
    padding.

%}

function welch_spectrum = get_welch_spectrum(signal, sampling_rate)
    
    %lunghezza finestra: scelgo il 38% della lunghezza totale del segnale
    window_length = 0.38*size(signal,2);
    
    %la successiva finestra deve avere un overlapping del 55% con la precedente
    overlapping_percentage = 0.55;
    % ... che in termini di punti sarebbero
    overlapping_points = window_length*overlapping_percentage;
    
    %lista frequenze che andremo ad analizzare: da 0 a 500 con risoluzione pari
    %a lunghezza_segnale/2+1 in quanto andremo ad applicare uno zero padding di
    %fino a 2000 (lunghezza segnale)
    list_of_frequencies = linspace(0, sampling_rate/2, floor(length(signal)/2)+1); 
    
    %salvo il risultato dello spettro totale: per ogni frequenza la sua
    %ampiezza
    welch_spectrum = zeros(1,length(list_of_frequencies));
    
    %Utilizzo la Hamming window come funzione di tapering
    hamming_window = 0.55-0.45*cos(2*pi*(1:window_length)/(window_length-1));
    
    %numero di spettri calcolati: mi servirà per poi calcolare la media
    number_of_spectrum = 1;
    
    %indico gli start point di ogni window considerando l'overlapping
    start_points_windows = 1:overlapping_points:length(signal)-window_length;
    
    %ad ogni step shift la window...
    for start_point = start_points_windows
        
        %ritaglio parte del segnale
        clipped_signal = signal(start_point:start_point+window_length-1);
    
        %lo smusso applicandogli la funzione di Hamming
        smoothed_clipped_signal = clipped_signal .* hamming_window;
    
        %calcolo coefficienti di Fourier su segnale con PADDING
        %2000-window_lenght
        fourier_coefficients = fft(smoothed_clipped_signal,length(signal)) / window_length;
    
        %spettro delle ampiezze
        amplitude_spectrum = 2*abs(fourier_coefficients(1:length(list_of_frequencies)));

        %trasformo in potenza
        power_spectrum = amplitude_spectrum.^2;

        %sommo tale spettro a quelli precedenti
        welch_spectrum = welch_spectrum + power_spectrum;
    
        %incremento il numero corrente di spettri calcolati
        number_of_spectrum = number_of_spectrum + 1;
    
    end
    
    %calcolo lo spettro medio
    welch_spectrum = welch_spectrum / number_of_spectrum;


    %{
        PARTE DI CONFRONTO - COMMENTARLA 
        Serve solo a confrontare lo spettro statico con quello di Welch
        ------------------------------------------------------------------------------------------------ DA COMMENTARE CODICE SOTTO! 
    

    figure(fig), clf
    l_signal = size(signal,2);
    s_fourier_coefficients = fft(signal) / l_signal;
    s_list_frequencies = linspace(0, sampling_rate/2, floor(l_signal/2)+1);
    subplot(211);
    a = 10*log10(2*abs(s_fourier_coefficients(1:length(s_list_frequencies))).^2);
    stem(s_list_frequencies, a);
    %title("Static spectrum con larghezza finestra %.6f e overlapping %.6f", num2str(larghezza_finestra), num2str(ooverlapping));
    set(gca,'xlim',[0 70])
    
    subplot(212);
    a = 10*log10(welch_spectrum);
    stem(list_of_frequencies,a);
    title("Welch Spectrum");

    set(gca,'xlim',[0 70])
   %}








