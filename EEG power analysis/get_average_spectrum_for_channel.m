




%{
    Questa funzione calcola per ogni canale i 13 spettri, dove ciascuno è
    calcolato secondo il metodo di Welch. Poi normalizza ciascuno dei 13 spettri con la relativa baseline. 
    Infine fa la media di tali spettri e
    questo costituisce l'average spectrum per quel canale.

    NB: 13 è un esempio del caso LO0195 sociale-sincrono
%}

function [average_spectrum_for_channel,hz] = get_average_spectrum_for_channel(true_trials, sampling_rate, baseline, do_baseline_normalization) %sarebbero gli ultimi 2000ms di ogni trial

    number_of_channels = size(true_trials,1);

    %lunghezza (in time points) singola trial
    length_single_trial = size(true_trials(1,:,1),2);

    %numero di trials
    number_of_trials = size(true_trials(1,1,:),3);

    %numero delle frequenze che andremo ad analizzare (NB: grazie allo zero
    %padding ne avremo 1001 invece che 351)
    hz = linspace(0, sampling_rate/2, floor(length_single_trial/2)+1); 
    number_of_frequencies_of_interest = size(hz,2);

    %creo una matrice 128x1001, ossia contenente per ogni canale i 1001
    %valori di potenza dello spettro medio ottenuto dalle sue 13 trial
    average_spectrum_for_channel = zeros(number_of_channels, number_of_frequencies_of_interest);

    %per ogni canale...
    for channel_i=1:number_of_channels

        %{
            avendo ogni canale "number_of_trials" numero di trials e volendo per ciascuna calcolare la potenza di "number_of_frequencies_of_interest"
            frequenze di interesse, allora creo una matrice
            number_of_frequencies_of_interest * number_of_trials dove per ogni
            colonna C mi dice quali sono le potenze delle
            "number_of_frequencies_of_interest" frequenze della trial C
        %} 

        power = zeros(number_of_frequencies_of_interest, number_of_trials);

        %per ognuna delle trial ottengo lo spettro di Welch
        for trial_i=1:number_of_trials

            %ottengo lo spettro di potenza secondo il metodo Welch
            welch_spectrum_trial_i = get_welch_spectrum(true_trials(channel_i,:,trial_i), sampling_rate);

            %lo salvo
            power(:,trial_i) = welch_spectrum_trial_i;
        end
 

        %Se si vuole fare la baseline normalization (versione vecchia)
        if do_baseline_normalization == true
            %normalizzo lo spettro di ogni trial con la propria baseline
            normalized_power = 10*log10(power ./ squeeze(baseline(channel_i,:,:))' );
            power = normalized_power;
            fprintf("Normalizzazione fatta.\n");
        else
            fprintf("Normalizzazione fatta in precedenza. Procedo direttamente al calcolo dello spettro medio per canale.\n");
        end
       

        %{
            power è una matrice 501x13, ossia ognuna delle 13 trial ha 501
            valori di potenza della relativa frequenza.
            Io voglio ottenere un unico spettro, che sarebbe la media tra
            tutti loro.
                trial1    trial2   trial2 ...
            f1:    10      12        5        --> voglio la media qui, per riga 
            f2:    4       8 ...
            f3
            ...
        %}

        %per ogni fi ho 16 valori, calcolo la media 
        average_power_spectrum_channel_i = mean(power,2);

        %lo salvo
        average_spectrum_for_channel(channel_i,:) = average_power_spectrum_channel_i;
        
    end
    

end
    