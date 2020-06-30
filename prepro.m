% Script that follows the Field Trip preprocessing tutorial
% see: http://www.fieldtriptoolbox.org/tutorial/continuous/#preprocessing-filtering-and-re-referencing
%
% Matt Kmiecik
% Started 30 June 2020

% Reading continuous EEG data into memory ----
cfg = [];
cfg.dataset     = './data/subj2.vhdr';
data_eeg        = ft_preprocessing(cfg);

% Plotting a channel ----
chansel  = 1;
plot(data_eeg.time{1}, data_eeg.trial{1}(chansel, :))
xlabel('time (s)')
ylabel('channel amplitude (uV)')
legend(data_eeg.label(chansel))

% Preprocessing, filtering, and re-referencing ----
cfg = [];
cfg.dataset     = './data/subj2.vhdr';
cfg.reref       = 'yes';
cfg.channel     = 'all';
cfg.implicitref = 'M1';         % the implicit (non-recorded) reference channel is added to the data representation
cfg.refchannel  = {'M1', '53'}; % the average of these two is used as the new reference, channel '53' corresponds to the right mastoid (M2)
data_eeg        = ft_preprocessing(cfg);

% Renaming channel 53 -> "M2"
chanindx = find(strcmp(data_eeg.label, '53'));
data_eeg.label{chanindx} = 'M2';

% Plotting
plot(data_eeg.time{1}, data_eeg.trial{1}(1:3,:));
legend(data_eeg.label(1:3));

% Reading HEOG channel
cfg = [];
cfg.dataset    = './data/subj2.vhdr';
cfg.channel    = {'51', '60'};
cfg.reref      = 'yes';
cfg.refchannel = '51';
data_eogh      = ft_preprocessing(cfg);

% Proof that HEOG is referenced to itself
figure
plot(data_eogh.time{1}, data_eogh.trial{1}(1,:));
hold on
plot(data_eogh.time{1}, data_eogh.trial{1}(2,:),'g');
legend({'51' '60'});

% Renames HEOG channel
data_eogh.label{2} = 'EOGH';
cfg = [];
cfg.channel = 'EOGH';
data_eogh   = ft_preprocessing(cfg, data_eogh); % nothing will be done, only the selection of the interesting channel

% Processing VEOG
cfg = [];
cfg.dataset    = './data/subj2.vhdr';
cfg.channel    = {'50', '64'};
cfg.reref      = 'yes';
cfg.refchannel = '50';
data_eogv      = ft_preprocessing(cfg);

% renames VEOG
data_eogv.label{2} = 'EOGV';
cfg = [];
cfg.channel = 'EOGV';
data_eogv   = ft_preprocessing(cfg, data_eogv); % nothing will be done, only the selection of the interesting channel

% Combining the HEOG, VEOG, and EEG data structures ----
cfg = [];
data_all = ft_appenddata(cfg, data_eeg, data_eogh, data_eogv);

% Segmenting continous data into trials ----
cfg = [];
cfg.dataset             = './data/subj2.vhdr';
cfg.trialdef.eventtype = '?';
dummy                   = ft_definetrial(cfg);

% Selecting specific triggers
cfg = [];
cfg.dataset             = './data/subj2.vhdr';
cfg.trialdef.eventtype = 'Stimulus';

% selects animals
cfg.trialdef.eventvalue = {'S111', 'S121', 'S131', 'S141'};
cfg_vis_animal          = ft_definetrial(cfg);

% selects tools
cfg.trialdef.eventvalue = {'S151', 'S161', 'S171', 'S181'};
cfg_vis_tool            = ft_definetrial(cfg);

% "Cutting out" or epoching trials based on condition
data_vis_animal = ft_redefinetrial(cfg_vis_animal, data_all);
data_vis_tool   = ft_redefinetrial(cfg_vis_tool,   data_all);

% Segmenting continuous data into one second pieces
cfg = [];
cfg.dataset              = './data/subj2.vhdr';
cfg.trialfun             = 'ft_trialfun_general';
cfg.trialdef.triallength = 1;   % duration in seconds
cfg.trialdef.ntrials     = inf; % number of trials, inf results in as many as possible
cfg                      = ft_definetrial(cfg);

% read the data from disk and segment it into 1-second pieces
data_segmented           = ft_preprocessing(cfg);

% Time based segmentation ----
% Another method is to read in as one long segment and further epoch into
% 1 second segments
% read it from disk as a single continuous segment
cfg = [];
cfg.dataset              = './data/subj2.vhdr';
data_cont                = ft_preprocessing(cfg);

% segment it into 1-second pieces
cfg = [];
cfg.length               = 1;
data_segmented           = ft_redefinetrial(cfg, data_cont);
