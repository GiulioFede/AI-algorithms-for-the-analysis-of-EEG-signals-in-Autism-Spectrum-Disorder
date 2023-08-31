

%{

    L'unica differenza tra la versione _old e quella _new è solo il fatto
    che la old prende in ingresso il dataset senza baseline correction e la
    implementa lei stesso via codice. Tale correzione è diversa da quella
    fatta su eeglab in quanto rimuove la baseline utilizzando le
    informazioni sulla potenza.

    Di seguito invece, la baseline è stata già rimossa. Si lavora quindi
    con un dataset di epoche per categorie già normalizzato.

%}


%Apro eeglab e carico (file-->load existing dataset->\...\LO0195_after_baseline_correction.set) cosi da avere altre informazioni che mi torneranno utili

%inserisci nome bambino/a
codice_bambino = "LO0334";

%inserisci il nome del tipo (es. sociale_sincrono)
tipo_dataset = "sociale_sincrono";

%carico le trial (es. quelle sociali sincrone)
trials = load ("D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\"+tipo_dataset+"\"+tipo_dataset+".mat");

%inserire il path dove verrà salvato il file summary_egg_power_per_channel.txt
path_summary_eeg_power_per_channel = 'D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\'+tipo_dataset+'\eeg_power_analysis_results\summary_egg_power_per_channel.txt';
%inserire il path dove verrà salvata la stessa informazione ma in csv senza
%altro testo di contorno
path_summary_eeg_power_per_channel_csv = 'D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\'+tipo_dataset+'\eeg_power_analysis_results\egg_power_per_channel.csv';

%inserire il path dove verrà salvato il file summary_egg_power_per_region.txt
path_summary_eeg_power_per_region = 'D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\'+tipo_dataset+'\eeg_power_analysis_results\summary_egg_power_per_region.txt';
%inserire il path dove verrà salvata la stessa informazione ma in csv senza
%altro testo di contorno
path_summary_eeg_power_per_region_csv = 'D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\'+tipo_dataset+'\eeg_power_analysis_results\egg_power_per_region.csv';

mkdir('D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\'+tipo_dataset+'\eeg_power_analysis_results');

trials = double(trials.('trials_'+tipo_dataset)); 


sampling_rate = EEG.srate;
sampling_period = 1/sampling_rate; % spazio temporale tra un campione e un altro
single_trial_duration = 3000; %ms
size_trials_set = size(trials);
number_of_trials = size_trials_set(2) / single_trial_duration;


%mi riporto le trials nella forma NChannel x LunghezzaTrial x NumeroTrials
%con cui sono più a mio agio
trials = reshape(trials, 128, single_trial_duration, []);

%adesso divido il dataset in due parti: uno che è stato già utilizzato per la baseline
%normalization, e il successivo per calcolare il Welch spectrum
baseline_dataset = zeros(128, 1000, number_of_trials);
baseline_dataset(:,:,:) = trials(:,1:1000,:); %copio solo i primi 1000 sample point di ogni trial

% In questa nuova versione ho solo bisogno di questo dataset
true_trials = zeros(128,2000,number_of_trials);
true_trials = trials(:,1001:end,:); %copio solo gli ultimi 2000 punti di ogni trial


%{

    Adesso per ogni canale voglio lo spettro medio considerando le 13
    trial.
    Lo spettro di ciascuna trial viene calcolato col metodo di Welch.

%}

[average_spectrum_for_channel,list_of_frequencies] = get_average_spectrum_for_channel(true_trials, sampling_rate, [], false);


%{
    
    Adesso che per ognuno dei 128 canali ho il suo spettro (frutto della
    media dei 13 spettri (normalizzati con baseline) delle 13 trial,
    calcolo il Relative Power per ogni banda.
    
%}

relative_power_band_per_channel = get_relative_power_band_per_channel(average_spectrum_for_channel,list_of_frequencies);

%salvo la matrice 128x5 dove ogni riga i contiene i valori di banda per
%ogni canale i-esimo
fid = fopen(path_summary_eeg_power_per_channel,'wt');
fprintf(fid, sprintf('Intervalli bande:\n delta=[1,3]Hz\n theta=[4,7]Hz\n alpha=[8,12]Hz\n beta=[13,24]Hz\n low gamma=[30,45]Hz\n\nDi seguito la matrice 128x5 contenente per ogni riga i valori di potenza (media) relativa per ogni banda del canale i-esimo:\n\n %s',strrep(mat2str(relative_power_band_per_channel),';','\n')));
fclose(fid);

%salvo le stesse informazioni, però in formato csv senza altre info
%testuali (servirà per venirmi meglio col parsing durante la fase di AI).
writematrix(relative_power_band_per_channel,path_summary_eeg_power_per_channel_csv) 


%{

    Adesso che per ogni canale ho i 5 relative power di ogni banda, calcolo
    5 mappe, ossia ogni mappa contiene la media dei valori che una sola banda
    assume su particolari regioni dello scalpo.

%}

MatrixOfRegionValuesPerBand = get_scalp_map_per_band(relative_power_band_per_channel, EEG.chanlocs);

%salvo la matrice 5x10 dove ogni riga i contiene i valori di potenza relative per
%regione per ogni banda i-esimo
fid = fopen(path_summary_eeg_power_per_region,'wt');
fprintf(fid, sprintf('Intervalli bande:\n delta=[1,3]Hz\n theta=[4,7]Hz\n alpha=[8,12]Hz\n beta=[13,24]Hz\n low gamma=[30,45]Hz\n\nDivisione dello scalpo:\n LFP=%s\n RFP=%s\n LF=%s\n RF=%s\n LT=%s\n LP=%s\n RP=%s\n RT=%s\n LO=%s\n RO=%s\n\nDi seguito la matrice 5x10 contenente per ogni riga i 10 valori di potenza media per regione della banda i-esima:\n %s',mat2str([18,19,21,22,23,25,26,32]),mat2str([1,2,3,4,8,9,10,14]),mat2str([7,12,13,20,24,27,28,29,30,33,34,38]),mat2str([5,105,106,111,112,116,117,118,121,122,123,124]),mat2str([39,43,44,45,48,49,50,56,57,58,63,64]),mat2str([31,35,36,37,41,42,47,52,53,59,54,60,61,67]),mat2str([77,78,79,80,85,86,87,91,92,93,98,103,104,110]),mat2str([95,96,97,99,100,101,102,107,108,109,113,114,115,116,119,120]),mat2str([65,66,68,69,70,71,73,74]),mat2str([76,82,83,84,88,89,90,94]),strrep(mat2str(MatrixOfRegionValuesPerBand),';','\n')));
fclose(fid);

%salvo le stesse informazioni, però in formato csv senza altre info
%testuali (servirà per venirmi meglio col parsing durante la fase di AI).
writematrix(MatrixOfRegionValuesPerBand,path_summary_eeg_power_per_region_csv) 


%salvo le figure
FigList = findobj(allchild(0), 'flat', 'Type', 'figure'); %ottengo nomi delle finestre (es. 5)
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigNumber   = get(FigHandle, 'Number');
  if FigNumber==''
      continue;
  else
    saveas(FigHandle, 'D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\'+tipo_dataset+'\eeg_power_analysis_results\'+FigNumber+".png");
  end
end























    
   


