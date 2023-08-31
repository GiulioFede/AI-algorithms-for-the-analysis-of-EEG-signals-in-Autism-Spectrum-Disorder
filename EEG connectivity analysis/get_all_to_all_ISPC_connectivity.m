


function all_to_all_matrix_connectivity = get_all_to_all_ISPC_connectivity(channels_trials,sampling_rate, root_path)

    [number_of_channels, length_of_single_trial, number_of_trials] = size(channels_trials);

    %bande da analizzare (inserisco gli estremi inferiori e superiori)
    delta = [1,3]; %Hz
    theta = [4,7]; %Hz
    alpha = [8,12]; %Hz
    beta =  [13,24]; %Hz
    low_gamma = [30,45]; %Hz

    bands = [delta; theta; alpha; beta; low_gamma];

    number_of_bands = 5;

    %voglio ottenere due all-to-all connectivity matrix per le frequenze da
    %1Hz fino a 45Hz (con salto nelle 25-29Hz)
    frequencies_of_interest = [];
    %numero di frequenze da analizzare all'interno di ogni banda
    number_of_inner_frequency_to_analyze = 15;
    for i=1:number_of_bands
        
        current_band = bands(i,:);
        frequencies_of_interest = [frequencies_of_interest , logspace(log10(current_band(1)),log10(current_band(2)),number_of_inner_frequency_to_analyze) ];

    end
    
    %{
        parametri per le complex Morlet wavelets
    %}
    
    %intervallo numero di cicli: determinano la larghezza della wavelet (numero
    %di picchi interni. All'aumentare del valore delle frequenze da analizzare,
    %aumento anche la larghezza della wavelet
    %n_cycles = linspace(4,13,length(frequencies_of_interest));
    n_cycles = logspace(log10(delta(1)),log10(low_gamma(2)),length(frequencies_of_interest));

    %tempo complex Morlet wavelet tra -1 e 1 con stesso sampling rate del segnale
    times_wavelet = -1:(1/sampling_rate):1; %va bene se dispari (2001) cosi da trovare il centro
    half_wavelet = (length(times_wavelet)-1) /2;

    %{
        parametri FFT
    %}
    kernel_length = length(times_wavelet);
    all_trials_length = length_of_single_trial*number_of_trials;
    length_of_result_convolution = kernel_length + all_trials_length -1;
    
    %{
        Creo le wavelet. Per cascuna di esse mi calcolo lo spettro e lo memorizzo. 
        Cosi che quando voglio estrarre una componente fi dal segnale,
        basta moltiplicare il suo spettro per quello di fi salvato in
        memoria. Questo dal teorema di convoluzione per evitare la pesante
        convoluzione tra segnale e kernel i-esimo.
    %}

    spectrum_of_wavelets = zeros(length(frequencies_of_interest), length_of_result_convolution);

    %per ogni frequenza di interesse...
    for fi=1:length(frequencies_of_interest)
    
        %creo la wavelet
        s = n_cycles(fi) / (2*pi*frequencies_of_interest(fi));
        comples_morlet_wavelet = exp(1i*2*pi*frequencies_of_interest(fi).*times_wavelet) .* exp( (-times_wavelet.^2) ./ (2*s^2));

        %calcolo spettro wavelet
        fourier_coefficients_of_current_wavelet = fft(comples_morlet_wavelet, length_of_result_convolution);

        %memorizzo lo spettro della wavelet corrente (potrei evitare di
        %normalizzare, tanto siamo interessati alla fase, ma lo lascio
        %cosi)
        spectrum_of_wavelets(fi, :) = fourier_coefficients_of_current_wavelet ./ max(fourier_coefficients_of_current_wavelet);
        
    end

    %{

        Per ogni canale e per ogni trial memorizzo l'andamento di fase di tutte le
        componenti frequenziali di interesse. La matrice è del tipo:
                    channels x frequency x times x trials
        
    %}

    time_series_of_phases = zeros(number_of_channels, size(frequencies_of_interest,2), length_of_single_trial, number_of_trials);

    %calcolo lo spettro di ogni trial in un colpo solo
    spectrum_of_trials = fft( reshape(channels_trials, number_of_channels, all_trials_length), length_of_result_convolution,2);

    %{
        adesso che ho gli spettri delle wavelet e delle trials, moltiplico
        ogni spettro delle trials per quello delle wavelet cosi
        "ritagliare" dello spettro di ogni trial solo il range di frequenze
        che ci interessano. Dopodichè da quello spettro effettuo la
        trasformata di Fourier inversa per ottenere a livello di segnale,
        quella componente frequenziale (sarebbe il segnale convoluto).

    %}

        for fi=1:length(frequencies_of_interest)

            %moltiplico spettri isolando le frequenze di interesse nello
            %spettro delle trial
            isolated_spectra = bsxfun(@times,spectrum_of_trials, spectrum_of_wavelets(fi,:));

            %trasformo gli spettri isolati nei rispettivi segnali
            %(componenti frequenziali) nel dominio del tempo
            components_of_interest = ifft(isolated_spectra, length_of_result_convolution, 2);
            components_of_interest = components_of_interest(:, half_wavelet+1:end-half_wavelet); %taglio via le ali in più

            components_of_interest = reshape(components_of_interest, size(channels_trials));
            %calcolo per ciascuna componente frequenziale estratta solo la
            %fase
            
            time_series_of_phases(:,fi,:,:) = angle(components_of_interest);

        end






        %{

            Connectivity: adesso che abbiamo per ogni canale e per ogni
            trial le componenti frequenziali, o meglio l'andamento delle
            loro fasi, possiamo inziare la connectivity analysis.

            Il tipo di connectivy analysis sarà over-trials, quindi se sono
            interessato a due canali X e Y, prendo le loro (esempio) 4 trials e
            calcolo per ciascuno la fase per una frequenza particolare (già
            fatto). Poi calcolo la differenza di fase tra la trial i-esima
            del canale X e quella i-esima del canale Y. Otterrò quindi 4
            andamenti di differenze di fasi. Calcolo l'ISPC utilizzando
            tutte i 4 andamenti precedenti estraendo i 4 valori (per
            calcolare l'ISPC) nello stesso istante di tempo.

        %}


        %definisco la finestra dove è presente lo stimolo. Questo è
        %presente nella finestra che va dai 2000ms ai 3000ms.
        time_window_stimulus = [1000, 3000];

        %inizializzo la matrice NumChannel x NumChannel x
        %FrequencyOfInterest cosi da avere FrequencyOfInterest matrici
        %ciascuna di dimensione NumChannel x NumChannel che mi dice,
        %ciascuna, come varia la connessione tra tutti gli elettrodi per
        %quella frequenza
        connectivity_matrix_by_frequency = zeros(number_of_channels, number_of_channels, length(frequencies_of_interest));

        %per ogni canale possibile...
        for channel_i=1:number_of_channels

            for channel_j=1:number_of_channels

               fprintf(sprintf("Calcolo matrice di connettività tra canale %d e canale %d \n", channel_i, channel_j));

               %calcolo la differenza euleriana tra le fasi delle
               %componenti frequenziali estratte
               phase_differences = squeeze( exp(1i*(time_series_of_phases(channel_i,:,:,:) - time_series_of_phases(channel_j,:,:,:)) ) );

               %calcolo ISPC
               ispc = abs( mean(phase_differences,3));

               %calcolo la media degli ISPC nella finestra dello stimolo
               connectivity_matrix_by_frequency(channel_i, channel_j, :) = mean( ispc(:, time_window_stimulus(1):time_window_stimulus(2)) ,2);

            end

        end


        %{

            Adesso abbiamo 35 all-to-all connectivity matrix, una per ogni
            frequenza delle bande viste.
            Vogliamo però ridurre le 35 matrici a solo 5 matrici, una per
            banda. Procederemo quindi a ottenere la matrice per la banda X
            facendo la media delle all-to-all connectivity matrix delle
            frequenze f che appartengono alla banda X

        %}
        start_index = dsearchn(frequencies_of_interest',delta(1));
        end_index = dsearchn(frequencies_of_interest',delta(2));
        connectivity_matrix_for_delta_band = get_average_connectivity_matrix(connectivity_matrix_by_frequency, start_index,end_index);
        writematrix(connectivity_matrix_for_delta_band,root_path+"\all_to_all_connectivity_delta.csv");
        
        start_index = dsearchn(frequencies_of_interest',theta(1));
        end_index = dsearchn(frequencies_of_interest',theta(2));
        connectivity_matrix_for_theta_band = get_average_connectivity_matrix(connectivity_matrix_by_frequency, start_index,end_index);
        writematrix(connectivity_matrix_for_theta_band,root_path+"\all_to_all_connectivity_theta.csv");

        start_index = dsearchn(frequencies_of_interest',alpha(1));
        end_index = dsearchn(frequencies_of_interest',alpha(2));
        connectivity_matrix_for_alpha_band = get_average_connectivity_matrix(connectivity_matrix_by_frequency, start_index,end_index);
        writematrix(connectivity_matrix_for_alpha_band,root_path+"\all_to_all_connectivity_alpha.csv");


        start_index = dsearchn(frequencies_of_interest',beta(1));
        end_index = dsearchn(frequencies_of_interest',beta(2));
        connectivity_matrix_for_beta_band = get_average_connectivity_matrix(connectivity_matrix_by_frequency, start_index,end_index);
        writematrix(connectivity_matrix_for_beta_band,root_path+"\all_to_all_connectivity_beta.csv");

        start_index = dsearchn(frequencies_of_interest',low_gamma(1));
        end_index = dsearchn(frequencies_of_interest',low_gamma(2));
        connectivity_matrix_for_low_gamma_band = get_average_connectivity_matrix(connectivity_matrix_by_frequency, start_index,end_index);
        writematrix(connectivity_matrix_for_low_gamma_band,root_path+"\all_to_all_connectivity_low_gamma.csv");

        %adesso possiamo plottare ogni matrice di connessione all-to-all per tutte
        %le bande di interesse

        figure(3), clf
        %matrice di connessione per la banda delta
        imagesc(squeeze(connectivity_matrix_for_delta_band));
        axis square
        set(gca, 'xtick', 1:number_of_channels, 'ytick', 1:number_of_channels);
        title("All-to-all connectivity matrix for delta band during stimulus period [1000,3000]ms");
        colorbar

        figure(4), clf
        %matrice di connessione per la banda theta
        imagesc(squeeze(connectivity_matrix_for_theta_band));
        axis square
        set(gca, 'xtick', 1:number_of_channels, 'ytick', 1:number_of_channels);
        title("All-to-all connectivity matrix for theta band during stimulus period [1000,3000]ms");
        colorbar

        figure(5), clf
        %matrice di connessione per la banda alpha
        imagesc(squeeze(connectivity_matrix_for_alpha_band));
        axis square
        set(gca, 'xtick', 1:number_of_channels, 'ytick', 1:number_of_channels);
        title("All-to-all connectivity matrix for alpha band during stimulus period [1000,3000]ms");
        colorbar

        figure(6), clf
        %matrice di connessione per la banda beta
        imagesc(squeeze(connectivity_matrix_for_beta_band));
        axis square
        set(gca, 'xtick', 1:number_of_channels, 'ytick', 1:number_of_channels);
        title("All-to-all connectivity matrix for beta band during stimulus period [1000,3000]ms");
        colorbar

        figure(7), clf
        %matrice di connessione per la banda low_gamma 
        imagesc(squeeze(connectivity_matrix_for_low_gamma_band));
        axis square
        set(gca, 'xtick', 1:number_of_channels, 'ytick', 1:number_of_channels);
        title("All-to-all connectivity matrix for low gamma band during stimulus period [1000,3000]ms");
        colorbar


        %{

            Stampiamo ancora le 5 matrici di connettività per banda, però stavolta
            per regione. Ogni regione ha M elettrodi che per una
            particolare matrice avranno, con TUTTI gli altri N elettrodi N
            valori di connettività. Quello che facciamo è raggruppare
            questi M vettori di lunghezza N e calcolare la media per cella.

        %}

        average_connectivity_matrix_delta = get_average_connectivity_matrix_per_region(connectivity_matrix_for_delta_band);
        writematrix(average_connectivity_matrix_delta,root_path+"\region_to_region_connectivity_delta.csv");

        average_connectivity_matrix_theta = get_average_connectivity_matrix_per_region(connectivity_matrix_for_theta_band);
        writematrix(average_connectivity_matrix_theta,root_path+"\region_to_region_connectivity_theta.csv");

        average_connectivity_matrix_alpha = get_average_connectivity_matrix_per_region(connectivity_matrix_for_alpha_band);
        writematrix(average_connectivity_matrix_alpha,root_path+"\region_to_region_connectivity_alpha.csv");
        
        average_connectivity_matrix_beta = get_average_connectivity_matrix_per_region(connectivity_matrix_for_beta_band);
        writematrix(average_connectivity_matrix_beta,root_path+"\region_to_region_connectivity_beta.csv");

        average_connectivity_matrix_low_gamma = get_average_connectivity_matrix_per_region(connectivity_matrix_for_low_gamma_band);
        writematrix(average_connectivity_matrix_low_gamma,root_path+"\region_to_region_connectivity_low_gamma.csv");

        %adesso possiamo plottare ogni matrice di connessione region-to-region per tutte
        %le frequenze di interesse

        labelNames = {'LFP','RFP','LF','RF','LT','LP','RP','RT','LO','RO'};

        figure(8), clf
        %matrice di connessione per la banda delta
        imagesc(squeeze(average_connectivity_matrix_delta));
        axis square
        set(gca,'XTick',1:number_of_channels);
        set(gca,'YTick',1:number_of_channels);
        set(gca,'XTickLabel',labelNames);
        set(gca,'YTickLabel',labelNames);
        title("Region-to-Region connectivity matrix for delta band during stimulus period [1000,3000]ms");
        colorbar

        figure(9), clf
        %matrice di connessione per la banda theta
        imagesc(squeeze(average_connectivity_matrix_theta));
        axis square
        set(gca,'XTick',1:number_of_channels);
        set(gca,'YTick',1:number_of_channels);
        set(gca,'XTickLabel',labelNames);
        set(gca,'YTickLabel',labelNames);
        title("Region-to-Region connectivity matrix for theta band during stimulus period [1000,3000]ms");
        colorbar

        figure(10), clf
        %matrice di connessione per la banda alpha
        imagesc(squeeze(average_connectivity_matrix_alpha));
        axis square
        set(gca,'XTick',1:number_of_channels);
        set(gca,'YTick',1:number_of_channels);
        set(gca,'XTickLabel',labelNames);
        set(gca,'YTickLabel',labelNames);
        title("Region-to-Region connectivity matrix for alpha band during stimulus period [1000,3000]ms");
        colorbar

        figure(11), clf
        %matrice di connessione per la banda beta
        imagesc(squeeze(average_connectivity_matrix_beta));
        axis square
        set(gca,'XTick',1:number_of_channels);
        set(gca,'YTick',1:number_of_channels);
        set(gca,'XTickLabel',labelNames);
        set(gca,'YTickLabel',labelNames);
        title("Region-to-Region connectivity matrix for beta band during stimulus period [1000,3000]ms");
        colorbar

        figure(12), clf
        %matrice di connessione per la banda low_gamma 
        imagesc(squeeze(average_connectivity_matrix_low_gamma));
        axis square
        set(gca,'XTick',1:number_of_channels);
        set(gca,'YTick',1:number_of_channels);
        set(gca,'XTickLabel',labelNames);
        set(gca,'YTickLabel',labelNames);
        title("Region-to-Region connectivity matrix for low gamma band during stimulus period [1000,3000]ms");
        colorbar

end


%prende tutte le connectivity matrix per certe frequenze di una banda e
%ritorna un unica connectivity matrix frutto della media di tutte loro


function average_connectivity_matrix = get_average_connectivity_matrix(connectivity_matrix_by_frequency,i_start, i_end)

    %seleziono solo le all-to-all connectivity matrix relative alla
    %frequenza nella banda
    sub_connectivity_matrix_by_frequency = connectivity_matrix_by_frequency(:,:, [i_start:i_end]);

    %ottengo il numero di matrici di connessione
    n_matrix = size(sub_connectivity_matrix_by_frequency,3);

    %ne calcolo la media
    average_connectivity_matrix = sum(sub_connectivity_matrix_by_frequency,3) ./ n_matrix;


end


%prende direttamente la average connectivity band per una banda e ritorna
%ancora una sola matrice, dove però ha raggruppato insieme gli elettrodi
%che fanno parte di una specifica regione
function average_connectivity_matrix_per_region = get_average_connectivity_matrix_per_region(average_connectivity_matrix)


    %matrice della connessione tra regioni
    average_connectivity_matrix_per_region = zeros(10,10);

    for region_i=1:10

        for region_j=1:10

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
    LT  = [39,43,44,45,48,49,50,56,57,58,63,64];
    LP  = [31,35,36,37,41,42,47,52,53,59,54,60,61,67];
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