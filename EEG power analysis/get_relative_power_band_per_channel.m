%{
    
    Adesso che per ognuno dei 128 canali ho il suo spettro (frutto della
    media dei 13 spettri (normalizzati con baseline) delle 13 trial,
    calcolo il Relative Power per ogni banda.
    
%}

function relative_power_band_per_channel = get_relative_power_band_per_channel(average_spectrum_per_channel, list_of_frequencies) %sarebbero gli spettri (medi) per canale

    %bande da analizzare (inserisco gli estremi inferiori e superiori)
    delta = [1,3]; %Hz
    theta = [4,7]; %Hz
    alpha = [8,12]; %Hz
    beta =  [13,24]; %Hz
    low_gamma = [30,45]; %Hz

    bands = [delta; theta; alpha; beta; low_gamma];

    number_of_bands = 5;
    
    % per ogni canale avrò quindi il Relative power di ognuna delle 5 bande
    relative_power_band_per_channel = zeros(128,number_of_bands);
    
    %per ogni canale...
    for channel_i=1:128

        %{
            calcolo la somma totale delle potenze assolute da 1Hz (estremo
            inferiore banda delta) fino a 45Hz (estremo superiore banda
            low_gamma)
        %}
         
        %trovo gli indici delle frequenze 1Hz e 45Hz
        %f_min = find(list_of_frequencies==delta(1));
        %f_max = find(list_of_frequencies==low_gamma(2));
        %total_ASP = sum(average_spectrum_per_channel(channel_i,f_min:f_max));


        %NEW: (IN CASO ELIMINARE QUESTE 5 RIGHE E DECOMMENTARE LE 3 RIGHE
        %SOPRA) escludo l'intervallo da 24 a 30 e le frequenze in mezzo
        %alle bande (es. 3.5Hz) cosi da arrivare a 1 come somma degli RSP
        f_min1 = find(list_of_frequencies==delta(1));
        f_max1 = find(list_of_frequencies==delta(2));
        f_min2 = find(list_of_frequencies==theta(1));
        f_max2 = find(list_of_frequencies==theta(2));
        f_min3 = find(list_of_frequencies==alpha(1));
        f_max3 = find(list_of_frequencies==alpha(2));
        f_min4 = find(list_of_frequencies==beta(1));
        f_max4 = find(list_of_frequencies==beta(2));
        f_min5 = find(list_of_frequencies==low_gamma(1));
        f_max5 = find(list_of_frequencies==low_gamma(2));
        total_ASP = sum(average_spectrum_per_channel(channel_i,[f_min1:f_max1, f_min2:f_max2,f_min3:f_max3,f_min4:f_max4,f_min5:f_max5]));

        fprintf("\n\n CANALE %d \n totale ASP=%s\n", channel_i, total_ASP);

        %per ogni banda calcolo l'absolute spectral power e poi il relative spectral power
        for band_i=1:number_of_bands
            
            current_band = bands(band_i,:);
            f_min_band = find(list_of_frequencies==current_band(1));
            f_max_band = find(list_of_frequencies==current_band(2));
            ASP_current_band = sum(average_spectrum_per_channel(channel_i,f_min_band:f_max_band));

            RSP_current_band = ASP_current_band / total_ASP;

            fprintf("Banda %s [%d,%d] con ASP=%s  e RSP=%s \n",mat2str(current_band), f_min_band,f_max_band, ASP_current_band, RSP_current_band );

            relative_power_band_per_channel(channel_i,band_i) = RSP_current_band;

        end

        fprintf("Totale = %s \n", num2str(sum(relative_power_band_per_channel(channel_i,:))));

        fprintf("Per il canale %d abbiamo: \n RP_banda_delta=%s \n RP_banda_theta=%s \n RP_banda_alpha=%s \n RP_banda_beta=%s \n RP_banda_low_gamma=%s \n\n\n", channel_i,num2str(relative_power_band_per_channel(channel_i,1)),num2str(relative_power_band_per_channel(channel_i,2)),num2str(relative_power_band_per_channel(channel_i,3)),num2str(relative_power_band_per_channel(channel_i,4)),num2str(relative_power_band_per_channel(channel_i,5)));

    end
    
end