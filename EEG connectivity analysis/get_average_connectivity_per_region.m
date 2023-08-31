function value_per_region = get_average_connectivity_per_region(average_connectivity_matrix)

    value_per_region=zeros(10,10);

    for region_i=1:10

        for region_j=1:10
            values = average_connectivity_matrix(get_indexes_of_electrodes_in_region(region_i),get_indexes_of_electrodes_in_region(region_j));
            mean_value = mean(values, 'All');
            value_per_region(region_i,region_j) = mean_value;
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