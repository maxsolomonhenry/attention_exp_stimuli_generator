function Filename = findStimFilename(InstIdx, MelIdx, DepthIdx)
    Inst = {'Tpt', 'Vln'};
    Mel = {'1', '2', '3', '4'};
    Depth = {'', '_vib20', '_vib30', '_vib40', '_vib50', '_vib60', '_vib70', ...
        '_vib80', '_vib90', '_vib100',};
    
    Filename = [Inst{InstIdx} Mel{MelIdx} Depth{DepthIdx} '.wav'];
end