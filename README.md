# unified-activity-segmentation-and-recognition
Source code for our Artificial Intelligence Journal (AIJ) 2021 paper "Weakly-supervised sensor-based activity segmentation and recognition via learning from distributions". 


### Abstract
>Sensor-based activity recognition aims to recognize users’ activities from multi-dimensional streams of sensor readings received from ubiquitous sensors. It has been shown that data segmentation and feature extraction are two crucial steps in developing machine learning-based models for sensor-based activity recognition. However, most previous studies were only focused on the latter step by assuming that data segmentation is done in advance. In practice, on the one hand, doing data segmentation on sensory streams is very challenging. On the other hand, if data segmentation is considered as a pre-process, the errors in data segmentation may be propagated to latter steps. Therefore, in this paper, we propose a unified weakly-supervised framework based on kernel embedding of distributions to jointly segment sensor streams, extract powerful features from each segment, and train a final classifier for activity recognition. We further offer an accelerated version for large-scale data by utilizing the technique of random Fourier features. We conduct experiments on four benchmark datasets to verify the effectiveness and scalability of our proposed framework.


### Data Preprocessing
Codes for data preprocessing on 4 datasets (Skoda, WISDM, HCI and PS) are in folder `./data`. The pre-processed datasets can be downloaded from [HERE](https://drive.google.com/drive/folders/1-ncyXXRg5qMmkJ-8I1xF3kW_3tAQRxXU?usp=sharing).


### Segmentation
The baselines `e.divisive` and `e.cp3o` are included in file`./code/[data_name]/1_ecp_baselines_all_full_len_parallel.R`. 

Other baselines, such as `BinSeg`, `BottomUp`, `KCpA`, `KCpE`, `PELT`, `window`, `pDPA`, are included in files `./code/[data_name]/baseline_[baseline_name].py/.R`.

The proposed method is included in `./code/[data_name]/proposed_seg_method` folder, wherein `data_3_iteration.m` is the core script.  

Then the `experi_classify_with_various_seg.m` can generate training and test data based on the predicted breakpoints. 

## Prediction

Finally, `./code/[dataset_name]/seg_plus_classify_experi` folder contains code to conduct classification task on segmented data.






Note that some of the baselines require the `ruptures` package. We have modified this package in order to run smoothly. The modified `ruptures` package is under `./modified_ruptures_package` folder.  


 If you find any of the codes helpful, kindly cite our paper. 

> ```
>@article{DBLP:journals/ai/QianPM21,
>  author    = {Hangwei Qian and
>               Sinno Jialin Pan and
>               Chunyan Miao},
>  title     = {Weakly-supervised sensor-based activity segmentation and recognition
>               via learning from distributions},
>  journal   = {Artif. Intell.},
>  volume    = {292},
>  pages     = {103429},
>  year      = {2021},
>  url       = {https://doi.org/10.1016/j.artint.2020.103429},
>  doi       = {10.1016/j.artint.2020.103429},
>  timestamp = {Tue, 09 Feb 2021 15:29:41 +0100},
>  biburl    = {https://dblp.org/rec/journals/ai/QianPM21.bib},
>  bibsource = {dblp computer science bibliography, https://dblp.org}
>}
> ```