%{
    
    Definiamo le seguenti regioni di interesse sullo scalpo:
 left frontopolar (LFP), right frontopolar (RFP), left frontal (LF), 
 right frontal (RF), left parietal (LP), right parietal (RP), left temporal (LT), 
 right temporal (RT), left occipital (LO), and right occipital (RO)

Calcoleremo 5 mappe, una per ogni banda, avendo cura di fare la media del
valore che quella banda assume in ogni elettrodo per regione.

%ritorna una matrice MatrixOfRegionValuesPerBand 5x10 contenente per ogni
banda i valori di regione ottenuti.
    
%}

function MatrixOfRegionValuesPerBand = get_scalp_map_per_band(relative_power_band_per_channel, chanlocs) 

    MatrixOfRegionValuesPerBand = zeros(5,10);

    %abbiamo 5 bande, quindi 5 mappe
    num_maps = 5;

    %definisco gli indici degli elettrodi che fanno parte di ogni regione
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

    %{

        Di seguito stampo le 5 mappe dove mostro il relative power per OGNI
        ELETTRODO.

    %}
    
    global map;

    map = [0,0,81;
3,0,84;
6,0,87;
9,0,89;
12,0,92;
15,0,95;
18,0,98;
21,0,100;
24,0,103;
27,0,106;
30,0,109;
33,0,111;
36,0,114;
39,0,117;
42,0,119;
45,0,122;
48,0,125;
51,0,128;
54,0,130;
57,0,133;
60,0,136;
63,0,139;
66,0,141;
69,0,144;
72,0,147;
75,0,150;
78,0,152;
81,0,155;
85,0,158;
88,0,161;
91,0,163;
94,0,166;
97,0,169;
100,0,172;
103,0,174;
106,0,177;
109,0,180;
112,0,182;
115,0,185;
118,0,188;
121,0,191;
124,0,193;
127,0,196;
130,0,199;
133,0,202;
136,0,204;
139,0,207;
142,0,210;
145,0,213;
148,0,215;
151,0,218;
154,0,221;
157,0,224;
160,0,226;
163,0,229;
166,0,232;
169,0,235;
172,0,237;
175,0,240;
178,0,243;
181,0,245;
184,0,248;
187,0,251;
190,0,254;
193,0,255;
194,0,252;
195,0,248;
196,0,245;
197,0,242;
198,0,238;
199,0,235;
200,0,232;
201,0,228;
202,0,225;
203,0,221;
204,0,218;
205,0,215;
206,0,211;
207,0,208;
208,0,205;
209,0,201;
210,0,198;
211,0,195;
212,0,191;
213,0,188;
214,0,185;
215,0,181;
216,0,178;
217,0,175;
218,0,171;
219,0,168;
219,0,165;
220,0,161;
221,0,158;
222,0,155;
223,0,151;
224,0,148;
225,0,145;
226,0,141;
227,0,138;
228,0,135;
229,0,131;
230,0,128;
231,0,124;
232,0,121;
233,0,118;
234,0,114;
235,0,111;
236,0,108;
237,0,104;
238,0,101;
239,0,98;
240,0,94;
241,0,91;
242,0,88;
243,0,84;
244,0,81;
245,0,78;
246,0,74;
247,0,71;
248,0,68;
249,0,64;
250,0,61;
251,0,58;
252,0,54;
253,0,51;
254,0,48;
255,0,44;
255,2,42;
255,6,42;
255,10,41;
255,14,40;
255,18,40;
255,22,39;
255,26,38;
255,30,38;
255,34,37;
255,38,37;
255,42,36;
255,46,35;
255,50,35;
255,54,34;
255,58,34;
255,62,33;
255,66,32;
255,70,32;
255,74,31;
255,78,30;
255,82,30;
255,86,29;
255,90,29;
255,94,28;
255,98,27;
255,102,27;
255,106,26;
255,110,25;
255,114,25;
255,118,24;
255,122,24;
255,126,23;
255,130,22;
255,134,22;
255,138,21;
255,142,21;
255,146,20;
255,150,19;
255,154,19;
255,158,18;
255,162,17;
255,167,17;
255,171,16;
255,175,16;
255,179,15;
255,183,14;
255,187,14;
255,191,13;
255,195,13;
255,199,12;
255,203,11;
255,207,11;
255,211,10;
255,215,9;
255,219,9;
255,223,8;
255,227,8;
255,231,7;
255,235,6;
255,239,6;
255,243,5;
255,247,4;
255,251,4;
255,255,3;
255,255,6;
255,255,10;
255,255,14;
255,255,18;
255,255,22;
255,255,26;
255,255,30;
255,255,34;
255,255,38;
255,255,42;
255,255,46;
255,255,50;
255,255,54;
255,255,58;
255,255,62;
255,255,66;
255,255,69;
255,255,73;
255,255,77;
255,255,81;
255,255,85;
255,255,89;
255,255,93;
255,255,97;
255,255,101;
255,255,105;
255,255,109;
255,255,113;
255,255,117;
255,255,121;
255,255,125;
255,255,129;
255,255,133;
255,255,137;
255,255,141;
255,255,145;
255,255,149;
255,255,153;
255,255,157;
255,255,161;
255,255,165;
255,255,169;
255,255,173;
255,255,176;
255,255,180;
255,255,184;
255,255,188;
255,255,192;
255,255,196;
255,255,200;
255,255,204;
255,255,208;
255,255,212;
255,255,216;
255,255,220;
255,255,224;
255,255,228;
255,255,232;
255,255,236;
255,255,240;
255,255,244;
255,255,248;
255,255,252;
255,255,255];

    map = map ./ 255;
    fh = figure(5);
    clf
    fh.WindowState = 'maximized';
    sgtitle("Relative Power Topographical Map for each band (each electrode shows its own RP value)")
    subplot(2,3,1);
    topoplotIndie(relative_power_band_per_channel(:,1), chanlocs, 'electrodes','labels','numcontour',0);
    title("Relative Power of delta band for each channel");
    caxis([0 1]);
    colorbar
    colormap(map)

    subplot(2,3,2);
    topoplotIndie(relative_power_band_per_channel(:,2), chanlocs, 'electrodes','labels','numcontour',0);
    title("Relative Power of theta band for each channel");
    caxis([0 1]);
    colorbar
    colormap(map)

    subplot(2,3,3);
    topoplotIndie(relative_power_band_per_channel(:,3), chanlocs, 'electrodes','labels','numcontour',0);
    title("Relative Power of alpha band for each channel");
    caxis([0 1]);
    colorbar
    colormap(map)

    subplot(2,3,4);
    topoplotIndie(relative_power_band_per_channel(:,4), chanlocs, 'electrodes','labels','numcontour',0);
    title("Relative Power of beta band for each channel");
    caxis([0 1]);
    colorbar
    colormap(map)

    subplot(2,3,5);
    topoplotIndie(relative_power_band_per_channel(:,5), chanlocs, 'electrodes','labels','numcontour',0);
    title("Relative Power of low gamma band for each channel");
    caxis([0 1]);
    colorbar
    colormap(map)


   %{

        Di seguito invece stampo le 5 mappe dove mostro il relative power per OGNI
        REGIONE.

   %}


    %mappa per la banda delta
    LFP_mean_rp = get_region_value(LFP,relative_power_band_per_channel(:,1));
    RFP_mean_rp = get_region_value(RFP,relative_power_band_per_channel(:,1));
    LF_mean_rp = get_region_value(LF,relative_power_band_per_channel(:,1));
    RF_mean_rp = get_region_value(RF,relative_power_band_per_channel(:,1));
    LT_mean_rp = get_region_value(LT,relative_power_band_per_channel(:,1));
    LP_mean_rp = get_region_value(LP,relative_power_band_per_channel(:,1));
    RP_mean_rp = get_region_value(RP,relative_power_band_per_channel(:,1));
    RT_mean_rp = get_region_value(RT,relative_power_band_per_channel(:,1));
    LO_mean_rp = get_region_value(LO,relative_power_band_per_channel(:,1));
    RO_mean_rp = get_region_value(RO,relative_power_band_per_channel(:,1));
    createTopoplotForRegion(LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp, ...
                            LFP,        RFP,        LF,        RF,        LT,        LP,        RP,        RT,        LO,        RO, ...
                            "delta", chanlocs,7);

    MatrixOfRegionValuesPerBand(1,:) = [LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp];
    fprintf("Relative Power of delta band for each region: %s \n", mat2str( MatrixOfRegionValuesPerBand(1,:)));
    
    %mappa per la banda theta
    LFP_mean_rp = get_region_value(LFP,relative_power_band_per_channel(:,2));
    RFP_mean_rp = get_region_value(RFP,relative_power_band_per_channel(:,2));
    LF_mean_rp = get_region_value(LF,relative_power_band_per_channel(:,2));
    RF_mean_rp = get_region_value(RF,relative_power_band_per_channel(:,2));
    LT_mean_rp = get_region_value(LT,relative_power_band_per_channel(:,2));
    LP_mean_rp = get_region_value(LP,relative_power_band_per_channel(:,2));
    RP_mean_rp = get_region_value(RP,relative_power_band_per_channel(:,2));
    RT_mean_rp = get_region_value(RT,relative_power_band_per_channel(:,2));
    LO_mean_rp = get_region_value(LO,relative_power_band_per_channel(:,2));
    RO_mean_rp = get_region_value(RO,relative_power_band_per_channel(:,2));
    createTopoplotForRegion(LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp, ...
                            LFP,        RFP,        LF,        RF,        LT,        LP,        RP,        RT,        LO,        RO, ...
                            "theta", chanlocs,8);
 
    MatrixOfRegionValuesPerBand(2,:) = [LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp];
    fprintf("Relative Power of theta band for each region: %s \n", mat2str( MatrixOfRegionValuesPerBand(2,:)));
    
    %mappa per la banda alpha
    LFP_mean_rp = get_region_value(LFP,relative_power_band_per_channel(:,3));
    RFP_mean_rp = get_region_value(RFP,relative_power_band_per_channel(:,3));
    LF_mean_rp = get_region_value(LF,relative_power_band_per_channel(:,3));
    RF_mean_rp = get_region_value(RF,relative_power_band_per_channel(:,3));
    LT_mean_rp = get_region_value(LT,relative_power_band_per_channel(:,3));
    LP_mean_rp = get_region_value(LP,relative_power_band_per_channel(:,3));
    RP_mean_rp = get_region_value(RP,relative_power_band_per_channel(:,3));
    RT_mean_rp = get_region_value(RT,relative_power_band_per_channel(:,3));
    LO_mean_rp = get_region_value(LO,relative_power_band_per_channel(:,3));
    RO_mean_rp = get_region_value(RO,relative_power_band_per_channel(:,3));
    createTopoplotForRegion(LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp, ...
                            LFP,        RFP,        LF,        RF,        LT,        LP,        RP,        RT,        LO,        RO, ...
                            "alpha", chanlocs,9);

    MatrixOfRegionValuesPerBand(3,:) = [LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp];
    fprintf("Relative Power of alpha band for each region: %s \n", mat2str( MatrixOfRegionValuesPerBand(3,:)));
    
    %mappa per la banda beta
    LFP_mean_rp = get_region_value(LFP,relative_power_band_per_channel(:,4));
    RFP_mean_rp = get_region_value(RFP,relative_power_band_per_channel(:,4));
    LF_mean_rp = get_region_value(LF,relative_power_band_per_channel(:,4));
    RF_mean_rp = get_region_value(RF,relative_power_band_per_channel(:,4));
    LT_mean_rp = get_region_value(LT,relative_power_band_per_channel(:,4));
    LP_mean_rp = get_region_value(LP,relative_power_band_per_channel(:,4));
    RP_mean_rp = get_region_value(RP,relative_power_band_per_channel(:,4));
    RT_mean_rp = get_region_value(RT,relative_power_band_per_channel(:,4));
    LO_mean_rp = get_region_value(LO,relative_power_band_per_channel(:,4));
    RO_mean_rp = get_region_value(RO,relative_power_band_per_channel(:,4));
    createTopoplotForRegion(LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp, ...
                            LFP,        RFP,        LF,        RF,        LT,        LP,        RP,        RT,        LO,        RO, ...
                            "beta", chanlocs,10);

    MatrixOfRegionValuesPerBand(4,:) = [LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp];
    fprintf("Relative Power of beta band for each region: %s \n", mat2str( MatrixOfRegionValuesPerBand(4,:)));

    %mappa per la banda low gamma
    LFP_mean_rp = get_region_value(LFP,relative_power_band_per_channel(:,5));
    RFP_mean_rp = get_region_value(RFP,relative_power_band_per_channel(:,5));
    LF_mean_rp = get_region_value(LF,relative_power_band_per_channel(:,5));
    RF_mean_rp = get_region_value(RF,relative_power_band_per_channel(:,5));
    LT_mean_rp = get_region_value(LT,relative_power_band_per_channel(:,5));
    LP_mean_rp = get_region_value(LP,relative_power_band_per_channel(:,5));
    RP_mean_rp = get_region_value(RP,relative_power_band_per_channel(:,5));
    RT_mean_rp = get_region_value(RT,relative_power_band_per_channel(:,5));
    LO_mean_rp = get_region_value(LO,relative_power_band_per_channel(:,5));
    RO_mean_rp = get_region_value(RO,relative_power_band_per_channel(:,5));
    createTopoplotForRegion(LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp, ...
                            LFP,        RFP,        LF,        RF,        LT,        LP,        RP,        RT,        LO,        RO, ...
                            "low gamma", chanlocs,11);

    
    MatrixOfRegionValuesPerBand(5,:) = [LFP_mean_rp,RFP_mean_rp,LF_mean_rp,RF_mean_rp,LT_mean_rp,LP_mean_rp,RP_mean_rp,RT_mean_rp,LO_mean_rp,RO_mean_rp];
    fprintf("Relative Power of low_gamma band for each region: %s \n", mat2str( MatrixOfRegionValuesPerBand(5,:)));
end



%ottengo il valore di relative power medio per una regione e per una banda
%particolare
function region_mean_rp = get_region_value(region, relative_power_band_of_interest) 
    
    % estraggo del vettore relative_power_band_of_interest solo i valori
    % relativi agli elettrodi che definiscono la regione
    rps_of_region = relative_power_band_of_interest(region);

    region_mean_rp = mean(rps_of_region);
    
    fprintf("%s \n",num2str(region_mean_rp));

end

function createTopoplotForRegion(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10, name_of_band, chanlocs, nf) 
    global map;
    value_of_map = zeros(1,128);

    value_of_map(a1) = v1;
    value_of_map(a2) = v2;
    value_of_map(a3) = v3;
    value_of_map(a4) = v4;
    value_of_map(a5) = v5;
    value_of_map(a6) = v6;
    value_of_map(a7) = v7;
    value_of_map(a8) = v8;
    value_of_map(a9) = v9;
    value_of_map(a10) = v10;

    fh = figure(nf);
    clf
    fh.WindowState = 'maximized';
    topoplotIndie(value_of_map, chanlocs, 'electrodes','labels','numcontour',0);
    title(sprintf("Relative Power of %s band for each region",name_of_band));
    colorbar
    caxis([0 1])
    colormap(map)

   

end