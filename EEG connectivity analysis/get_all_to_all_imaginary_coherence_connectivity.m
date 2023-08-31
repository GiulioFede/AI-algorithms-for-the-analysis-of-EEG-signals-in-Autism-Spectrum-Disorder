

function imaginary_coherence_matrix = get_all_to_all_imaginary_coherence_connectivity(channels_trials,sampling_rate,root_path)


    [number_of_channels, length_of_single_trial, number_of_trials] = size(channels_trials);
    
    %bande da analizzare (inserisco gli estremi inferiori e superiori)
    delta = [1,3]; %Hz
    theta = [4,7]; %Hz
    alpha = [8,12]; %Hz
    beta =  [13,24]; %Hz
    low_gamma = [30,45]; %Hz

    bands = [delta; theta; alpha; beta; low_gamma];

    number_of_bands = 5;

    frequencies_of_interest  =  [];

    %numero di frequenze da analizzare all'interno di ogni banda
    number_of_inner_frequency_to_analyze = 15;

    %per ogni banda, decido di analizzare 15 frequenze
    fprintf("Creo frequenze di interesse.\n");
    for i=1:number_of_bands
        
        current_band = bands(i,:);
        frequencies_of_interest = [frequencies_of_interest , logspace(log10(current_band(1)),log10(current_band(2)),number_of_inner_frequency_to_analyze) ];

    end

    %indico la finestra temporale di quando avviene lo stimolo (che si muove)
    times_stimulus = 1000:3000;

    %waveler parameter
    times_wavelet = -1:1/sampling_rate:1;
    half_wavelet = (length(times_wavelet)-1)/2;
    wavelet_length = length(times_wavelet);
    num_cycles    = logspace(log10(delta(1)),log10(low_gamma(2)),length(frequencies_of_interest));

    %parametri fft
    all_trials_length = length_of_single_trial*number_of_trials;
    convolution_length = wavelet_length+all_trials_length-1;

    %creo una matrice di dimensione NxNxF, ossia 128x128xNumeroFrequenze
    imaginary_coherence_matrix = zeros(number_of_channels, number_of_channels, length(frequencies_of_interest));


    %per ogni canale i...
    for channel_i = 1:number_of_channels

        fprintf("Calcolo connessioni del canale %d \n", channel_i);
                
        %per ogni canale j...
        for channel_j = 1:number_of_channels

            chanidx = zeros(1,2);
            chanidx(1,1) = channel_i;
            chanidx(1,2) = channel_j;
 
            %calcolo lo spettro di ogni trial. NB: ognuno di loro conterrà i (es.) 12 spettri
            %concatenati l'uno accanto all'altro
            channel_i_trials_spectra = fft(reshape(channels_trials(chanidx(1),:,:),1,all_trials_length),convolution_length);
            channel_j_trials_spectra = fft(reshape(channels_trials(chanidx(2),:,:),1,all_trials_length),convolution_length);
            
            % Imaginary Coherence: è una matrice che conterrà per tutte le
            % frequenze di interesse i valori di imaginary coherence per
            % ogni istante temporale. In realtà, siccome poi mi interesserà
            % solo dall'istante dello stimolo in poi, salverò quelle
            imaginary_coherence = zeros(length(frequencies_of_interest));

            
            %per ogni frequenza di interesse...
            for fi=1:length(frequencies_of_interest)
                
                %fprintf(sprintf("Calcolo connessione tra canale %d e %d alla frequenza %s \n", channel_i, channel_j, num2str(frequencies_of_interest(fi))));
                %creo la wavelet
                s =num_cycles(fi) / (2*pi*frequencies_of_interest(fi));
                wavelet = exp(2*1i*pi*frequencies_of_interest(fi).*times_wavelet) .* exp(-times_wavelet.^2./(2*(s^2)));
                wavelet_spectrum = fft(wavelet, convolution_length);

                %prendo gli spettri già calcolati delle (es.) 12 trial e ne isolo solo la
                %corrente frequenza fi
                fi_component_channel_i = ifft(wavelet_spectrum .* channel_i_trials_spectra, convolution_length);
                %taglio le ali
                fi_component_channel_i = fi_component_channel_i(half_wavelet+1: end-half_wavelet);
                %ho ottenuto (es.) 13 segnali che sarebbero ciascuna la componente
                %frequenziale fi di una delle (es) 13 trial. Adesso rimetto tutto sotto
                %forma di 3000x13
                fi_component_channel_i_per_trial = reshape(fi_component_channel_i, length_of_single_trial, number_of_trials);

                %faccio lo stesso per il canale 2
                fi_component_channel_j = ifft(wavelet_spectrum .* channel_j_trials_spectra, convolution_length);
                fi_component_channel_j = fi_component_channel_j(half_wavelet+1: end-half_wavelet);
                fi_component_channel_j_per_trial = reshape(fi_component_channel_j, length_of_single_trial, number_of_trials);


                % ::::::::::::::::::::::::::::::::::::::::::::::::::::
                % mean sta per l'expected value
                cross_spectral_density_1 = sum(fi_component_channel_i_per_trial .* conj(fi_component_channel_i_per_trial),2); 
                cross_spectral_density_2 = sum(fi_component_channel_j_per_trial .* conj(fi_component_channel_j_per_trial),2);
                cross_spectral_density = sum(fi_component_channel_i_per_trial .* conj(fi_component_channel_j_per_trial),2);

                %calcolo la coherence
                coherence = cross_spectral_density(times_stimulus) ./ sqrt(cross_spectral_density_1(times_stimulus) .* cross_spectral_density_2(times_stimulus));
                %prendo la parte immaginaria e poi applico il modulo
                imaginary_coherence(fi) = mean(abs( imag(coherence) ));
                %::::::::::::::::::::::::::::::::::::::::::::::::::::::::

            end


            for f=1:length(frequencies_of_interest)
                imaginary_coherence_matrix(channel_i, channel_j,f) = imaginary_coherence(f);
            end


            
        end

      
    end

    %{

            Adesso ho una imaginary_coherence_matrix 128x128xF dove F sono
            il numero di frequenze da analizzare. Voglio per ogni banda una
            sola 128x128 matrice. Pertanto per ogni banda prendo le N
            matrici 128x128xf dove f appartiene alla banda. Ne calcolo la
            media. 

    %}

    %ordino gli elettrodi raggruppandoli per regione
    ordered_electrodes = [18,19,21,22,23,25,26,32,1,2,3,4,8,9,10,14,7,12,13,20,24,27,28,29,30,33,34,38,5,105,106,111,112,116,117,118,121,122,123,124,39,43,44,45,46,48,49,50,56,57,58,63,64,31,35,36,37,40,41,42,47,51,52,53,59,54,60,61,67,77,78,79,80,85,86,87,91,92,93,98,103,104,110,95,96,97,99,100,101,102,107,108,109,113,114,115,116,119,120,65,66,68,69,70,71,73,74,76,82,83,84,88,89,90,94];
    
    %massima connessione
    %imaginary_coherence_matrix per banda delta
    start_index = dsearchn(frequencies_of_interest',delta(1));
    end_index = dsearchn(frequencies_of_interest',delta(2));
    imaginary_coherence_matrix_delta_band = mean(imaginary_coherence_matrix(:,:,start_index:end_index),3);
    %imaginary_coherence_matrix per banda theta
    start_index = dsearchn(frequencies_of_interest',theta(1));
    end_index = dsearchn(frequencies_of_interest',theta(2));
    imaginary_coherence_matrix_theta_band = mean(imaginary_coherence_matrix(:,:,start_index:end_index),3);
    %imaginary_coherence_matrix per banda alpha
    start_index = dsearchn(frequencies_of_interest',alpha(1));
    end_index = dsearchn(frequencies_of_interest',alpha(2));
    imaginary_coherence_matrix_alpha_band = mean(imaginary_coherence_matrix(:,:,start_index:end_index),3);
    %imaginary_coherence_matrix per banda beta
    start_index = dsearchn(frequencies_of_interest',beta(1));
    end_index = dsearchn(frequencies_of_interest',beta(2));
    imaginary_coherence_matrix_beta_band = mean(imaginary_coherence_matrix(:,:,start_index:end_index),3);
    %imaginary_coherence_matrix per banda low_gamma
    start_index = dsearchn(frequencies_of_interest',low_gamma(1));
    end_index = dsearchn(frequencies_of_interest',low_gamma(2));
    imaginary_coherence_matrix_low_gamma_band = mean(imaginary_coherence_matrix(:,:,start_index:end_index),3);

    max_connection_value_delta = max(reshape(imaginary_coherence_matrix_delta_band, [1,128*128*length(number_of_inner_frequency_to_analyze)]));
    max_connection_value_theta = max(reshape(imaginary_coherence_matrix_theta_band, [1,128*128*length(number_of_inner_frequency_to_analyze)]));
    max_connection_value_alpha = max(reshape(imaginary_coherence_matrix_alpha_band, [1,128*128*length(number_of_inner_frequency_to_analyze)]));    
    max_connection_value_beta = max(reshape(imaginary_coherence_matrix_beta_band, [1,128*128*length(number_of_inner_frequency_to_analyze)]));
    max_connection_value_low_gamma = max(reshape(imaginary_coherence_matrix_low_gamma_band, [1,128*128*length(number_of_inner_frequency_to_analyze)]));

    max_connection_value = max([max_connection_value_delta,max_connection_value_theta,max_connection_value_alpha,max_connection_value_beta,max_connection_value_low_gamma]);


    writematrix(imaginary_coherence_matrix_delta_band,root_path+"\all_to_all_connectivity_delta.csv");

    fh = figure(100);
    clf
    fh.WindowState = 'maximized';
    B = squeeze(imaginary_coherence_matrix_delta_band);
    imagesc(B(ordered_electrodes, ordered_electrodes));
    plot_grid();
    axis square
    ticksarray=[5,13,23,35,47,62,76,93,104,112];
    tickslabels={'LFP','RFP','LF','RF','LT','LP','RP','RT','LO','RO'};
    set(gca,'XTick',ticksarray)
    set(gca,'XTickLabel',tickslabels)
    set(gca,'YTick',ticksarray)
    set(gca,'YTickLabel',tickslabels)
    title("All-to-all connectivity matrix for delta band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_value]);

    
    writematrix(imaginary_coherence_matrix_theta_band,root_path+"\all_to_all_connectivity_theta.csv");

    fh = figure(101);
    clf
    fh.WindowState = 'maximized';
    B = squeeze(imaginary_coherence_matrix_theta_band);
    imagesc(B(ordered_electrodes, ordered_electrodes));
    plot_grid();
    axis square
    ticksarray=[5,13,23,35,47,62,76,93,104,112];
    tickslabels={'LFP','RFP','LF','RF','LT','LP','RP','RT','LO','RO'};
    set(gca,'XTick',ticksarray)
    set(gca,'XTickLabel',tickslabels)
    set(gca,'YTick',ticksarray)
    set(gca,'YTickLabel',tickslabels)
    title("All-to-all connectivity matrix for theta band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_value]);

    writematrix(imaginary_coherence_matrix_alpha_band,root_path+"\all_to_all_connectivity_alpha.csv");

    fh = figure(102);
    clf
    fh.WindowState = 'maximized';
    B = squeeze(imaginary_coherence_matrix_alpha_band);
    imagesc(B(ordered_electrodes, ordered_electrodes));
    plot_grid();
    axis square
    ticksarray=[5,13,23,35,47,62,76,93,104,112];
    tickslabels={'LFP','RFP','LF','RF','LT','LP','RP','RT','LO','RO'};
    set(gca,'XTick',ticksarray)
    set(gca,'XTickLabel',tickslabels)
    set(gca,'YTick',ticksarray)
    set(gca,'YTickLabel',tickslabels)
    title("All-to-all connectivity matrix for alpha band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_value]);

    writematrix(imaginary_coherence_matrix_beta_band,root_path+"\all_to_all_connectivity_beta.csv");

    fh = figure(103);
    clf
    fh.WindowState = 'maximized';
    B = squeeze(imaginary_coherence_matrix_beta_band);
    imagesc(B(ordered_electrodes, ordered_electrodes));
    plot_grid();
    axis square
    ticksarray=[5,13,23,35,47,62,76,93,104,112];
    tickslabels={'LFP','RFP','LF','RF','LT','LP','RP','RT','LO','RO'};
    set(gca,'XTick',ticksarray)
    set(gca,'XTickLabel',tickslabels)
    set(gca,'YTick',ticksarray)
    set(gca,'YTickLabel',tickslabels)
    title("All-to-all connectivity matrix for beta band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_value]);

    writematrix(imaginary_coherence_matrix_low_gamma_band,root_path+"\all_to_all_connectivity_low_gamma.csv");

    fh = figure(104);
    clf
    fh.WindowState = 'maximized';
    B = squeeze(imaginary_coherence_matrix_low_gamma_band);
    imagesc(B(ordered_electrodes, ordered_electrodes));
    plot_grid();
    axis square
    ticksarray=[5,13,23,35,47,62,76,93,104,112];
    tickslabels={'LFP','RFP','LF','RF','LT','LP','RP','RT','LO','RO'};
    set(gca,'XTick',ticksarray)
    set(gca,'XTickLabel',tickslabels)
    set(gca,'YTick',ticksarray)
    set(gca,'YTickLabel',tickslabels)
    title("All-to-all connectivity matrix for low gamma band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_value]);

    %{

        Stampiamo ancora le 5 matrici di connettività per banda, però stavolta
        per regione. Ogni regione ha M elettrodi che per una
        particolare matrice avranno, con TUTTI gli altri N elettrodi N
        valori di connettività. Quello che facciamo è raggruppare
        questi M vettori di lunghezza N e calcolare la media per cella.

    %}

    average_connectivity_matrix_delta = get_average_connectivity_per_region(imaginary_coherence_matrix_delta_band);
    writematrix(average_connectivity_matrix_delta,root_path+"\region_to_region_connectivity_delta.csv");

    average_connectivity_matrix_theta = get_average_connectivity_per_region(imaginary_coherence_matrix_theta_band);
    writematrix(average_connectivity_matrix_theta,root_path+"\region_to_region_connectivity_theta.csv");

    average_connectivity_matrix_alpha = get_average_connectivity_per_region(imaginary_coherence_matrix_alpha_band);
    writematrix(average_connectivity_matrix_alpha,root_path+"\region_to_region_connectivity_alpha.csv");

    average_connectivity_matrix_beta = get_average_connectivity_per_region(imaginary_coherence_matrix_beta_band);
    writematrix(average_connectivity_matrix_beta,root_path+"\region_to_region_connectivity_beta.csv");

    average_connectivity_matrix_low_gamma = get_average_connectivity_per_region(imaginary_coherence_matrix_low_gamma_band);
    writematrix(average_connectivity_matrix_low_gamma,root_path+"\region_to_region_connectivity_low_gamma.csv");

    max_connection_region_delta = max(reshape(average_connectivity_matrix_delta,[1,100]));
    max_connection_region_theta = max(reshape(average_connectivity_matrix_theta,[1,100]));
    max_connection_region_alpha = max(reshape(average_connectivity_matrix_alpha,[1,100]));
    max_connection_region_beta = max(reshape(average_connectivity_matrix_beta,[1,100]));
    max_connection_region_low_gamma = max(reshape(average_connectivity_matrix_low_gamma,[1,100]));

    max_connection_region = max([max_connection_region_delta,max_connection_region_theta,max_connection_region_alpha,max_connection_region_beta,max_connection_region_low_gamma]);

    %adesso possiamo plottare ogni matrice di connessione region-to-region per tutte
    %le frequenze di interesse

    labelNames = {'LFP','RFP','LF','RF','LT','LP','RP','RT','LO','RO'};

    fh = figure(105);
    clf
    fh.WindowState = 'maximized';
    %matrice di connessione per la banda delta
    imagesc(squeeze(average_connectivity_matrix_delta));
    axis square
    set(gca,'XTick',1:number_of_channels);
    set(gca,'YTick',1:number_of_channels);
    set(gca,'XTickLabel',labelNames);
    set(gca,'YTickLabel',labelNames);
    title("Region-to-Region connectivity matrix for delta band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_region]);

    fh = figure(106);
    clf
    fh.WindowState = 'maximized';
    %matrice di connessione per la banda theta
    imagesc(squeeze(average_connectivity_matrix_theta));
    axis square
    set(gca,'XTick',1:number_of_channels);
    set(gca,'YTick',1:number_of_channels);
    set(gca,'XTickLabel',labelNames);
    set(gca,'YTickLabel',labelNames);
    title("Region-to-Region connectivity matrix for theta band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_region]);

    fh = figure(107);
    clf
    fh.WindowState = 'maximized';
    %matrice di connessione per la banda alpha
    imagesc(squeeze(average_connectivity_matrix_alpha));
    axis square
    set(gca,'XTick',1:number_of_channels);
    set(gca,'YTick',1:number_of_channels);
    set(gca,'XTickLabel',labelNames);
    set(gca,'YTickLabel',labelNames);
    title("Region-to-Region connectivity matrix for alpha band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_region]);

    fh = figure(108);
    clf
    fh.WindowState = 'maximized';
    %matrice di connessione per la banda beta
    imagesc(squeeze(average_connectivity_matrix_beta));
    axis square
    set(gca,'XTick',1:number_of_channels);
    set(gca,'YTick',1:number_of_channels);
    set(gca,'XTickLabel',labelNames);
    set(gca,'YTickLabel',labelNames);
    title("Region-to-Region connectivity matrix for beta band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_region]);

    fh = figure(109);
    clf
    fh.WindowState = 'maximized';
    %matrice di connessione per la banda low_gamma 
    imagesc(squeeze(average_connectivity_matrix_low_gamma));
    axis square
    set(gca,'XTick',1:number_of_channels);
    set(gca,'YTick',1:number_of_channels);
    set(gca,'XTickLabel',labelNames);
    set(gca,'YTickLabel',labelNames);
    title("Region-to-Region connectivity matrix for low gamma band during stimulus period [1000,3000]ms using Imaginary Coherence");
    colorbar
    set(gca,'CLim', [0, max_connection_region]);

    try
        %salvo le figure
        mkdir(root_path+'\images\');
        FigList = findobj(allchild(0), 'flat', 'Type', 'figure'); %ottengo nomi delle finestre (es. 5)
        for iFig = 1:length(FigList)
          FigHandle = FigList(iFig);
          FigNumber   = get(FigHandle, 'Number');
          if FigNumber==''
              continue;
          else
            saveas(FigHandle, root_path+'\images\'+FigNumber+".png");
          end
        end
    catch
        %nothing
    end
   
end

%prende direttamente la average connectivity band per una banda e ritorna
%ancora una sola matrice, dove però ha raggruppato insieme gli elettrodi
%che fanno parte di una specifica regione
function average_connectivity_matrix_per_region = get_average_connectivity_matrix_per_region(average_connectivity_matrix)


    %matrice della connessione tra regioni
    average_connectivity_matrix_per_region = zeros(10,10);

    for region_i=1:10

        for region_j=1:10

                %se le regioni sono uguali, pongo a 0
                if region_i == region_j
                    average_connectivity_matrix_per_region(region_i, region_j) = 0;
                    continue
                end

                %ottengo gli indici della regione i
                indexes_i = get_indexes_of_electrodes_in_region(region_i);

                %ottengo gli indici della regione j
                indexes_j = get_indexes_of_electrodes_in_region(region_j);

                %creo un vettore contenente la media delle connessioni
                %massime che ogni elettrodo nella regione j ha (se c'è)
                maximum_connection_value_per_electrode_j = zeros(1,size(indexes_j,2));
                %tiene conto per ogni elettrodo j il numero di connessioni
                %massime che ha avuto
                maximum_connection_count_per_electrode_j = zeros(1,size(indexes_j,2));


                %per ogni elettrodo della regione i...
                for index_el=1:size(indexes_i,2)

                    %estraggo l'elettrodo della regione i corrente
                    el = indexes_i(index_el);

                    %estraggo i valori di connessione che el ha con tutti gli elettrodi della regione j
                    connection_value_for_el = average_connectivity_matrix(el, indexes_j);

                    %estraggo la connessione massima
                    max_conn_value = max(connection_value_for_el);

                    %estraggo l'elettrodo con cui ha massima connessione
                    indexes_of_max_connection = find(connection_value_for_el==max_conn_value);

                    %gli indici (raramente) potrebbero essere più di uno.
                    %Non ci interessa, tranne nel caso in cui le regioni
                    %sono uguali e il valore di connessione è 1. 
                    %Bisogna scegliere l'elettrodo uguale a quello corrente
                    connected_to = -1;
                    if(size(indexes_of_max_connection,2)>1 && max_conn_value==1 && region_i==region_j)

                        connected_to = index_el;
                    else
                        connected_to = indexes_of_max_connection(1); %prendo il primo di default
                    end

                    %aggiungo alle connessioni vincenti che tale elettrodo ha
                    maximum_connection_value_per_electrode_j(connected_to) =  maximum_connection_value_per_electrode_j(connected_to) + max_conn_value;
                    maximum_connection_count_per_electrode_j(connected_to) = maximum_connection_count_per_electrode_j(connected_to) + 1;

                end

                %adesso abbiamo per ogni elettrodo della regione j un
                %valore che indica la somma delle connessioni massime che
                %ha avuto. Calcolo la connessione tra le due regioni:
                res = maximum_connection_value_per_electrode_j ./ maximum_connection_count_per_electrode_j;
                res(isnan(res)) = 0;
                connection_between_region_i_j = sum(res) / size(indexes_j,2);
                
                %la salvo
                average_connectivity_matrix_per_region(region_i, region_j) = connection_between_region_i_j;

        end


    end

   


end



function indexes = get_indexes_of_electrodes_in_region(i)

    %definisco gli indici degli elettrodi che fanno parte di ogni regione
    %(in totale sono 88)
    LFP = [18,19,21,22,23,25,26,32];
    RFP = [1,2,3,4,8,9,10,14];
    LF  = [7,12,13,20,24,27,28,29,30,33,34,38];
    RF  = [5,105,106,111,112,116,117,118,121,122,123,124];
    LT  = [39,43,44,45,46,48,49,50,56,57,58,63,64];
    LP  = [31,35,36,37,40,41,42,47,51,52,53,59,54,60,61,67];
    RP  = [77,78,79,80,85,86,87,91,92,93,98,103,104,110];
    RT  = [95,96,97,99,100,101,102,107,108,109,113,114,115,116,119,120];
    LO  = [65,66,68,69,70,71,73,74];
    RO  = [76,82,83,84,88,89,90,94];

    switch i
        case 1
            indexes = LFP;
        case 2
            indexes = RFP;
        case 3
           indexes = LF;
        case 4
           indexes = RF;
        case 5
           indexes = LT;
        case 6
           indexes = LP;
        case 7
           indexes = RP;
        case 8
           indexes = RT;
        case 9
           indexes = LO;
        otherwise
           indexes = RO;
    end

end