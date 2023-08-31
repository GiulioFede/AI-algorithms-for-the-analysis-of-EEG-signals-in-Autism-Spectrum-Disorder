
%Questa funzione restituisce i valori di baseline per tutte le trial



%{
    

    Ritorna una matrice 128x13x500, ossia per ognuno dei 128 canali e per
    ognuna delle relative 13 trial, abbiamo 500 valori di baseline.
%}

function baseline = get_baseline_factors(baseline_dataset, sampling_rate) %sarebbero le parti di trial da cui estrarre i fattori baseline

    number_of_trials = size(baseline_dataset,3);
    number_of_channels = size(baseline_dataset,1);
    
    %conterrà, per ogni canale, i valori di baseline per ogni trial
    baseline = zeros(number_of_channels,number_of_trials, 501);


    for channel_i=1:number_of_channels

        %specifico il canale di interesse
        channel_of_interest = channel_i;

        %calcolo baseline di ogni trial per il canale di interesse
        %creo matrice Nx1000, ossia ogni riga conterrà le 501 potenze calcolate
        %per quella trial
        baseline_channel = zeros(number_of_trials,501);

        for trial_i=1:number_of_trials
                current_trial = baseline_dataset(channel_of_interest,:,trial_i);

                fourier_coefficients_trial_i = fft(current_trial)/ 1000;

                frequency_list = linspace(0, sampling_rate/2, floor(1000/2)+1);
                
                %aggiungo i fattori baseline per questa trial alla matrice baseline
                baseline_channel(trial_i, :) = (2*abs(fourier_coefficients_trial_i(1:length(frequency_list)))).^2;
            
                %{
                figure(104), clf;
                stem(frequency_list, (baseline_channel(trial_i, :)));
                xlabel("Frequency (HZ)")
                set(gca,'xlim',[0 60])
                %}
                
    
        end

        baseline(channel_of_interest,:,:) = baseline_channel(:,:);

    end
    
    
    
    
   
    
    

end