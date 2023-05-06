# life_game

undergraduate year 3 闲来无事编写
基于python自带TKinter pack

v4为最新版本
有基本的选择，取消，运行，还原，记录，缩放移动功能
另有确定宽度和高度后，选择点的数量，然后遍历出运行时间最长的十个组合，并记录位置方便重放的功能

但运行一段时间会卡顿，初步筛查为TKinter画布元素堆叠导致，删单个元素无效，现采用整体重画来消除卡顿

整体框架：https://pipirima.top/Conway%E7%94%9F%E5%91%BD%E6%B8%B8%E6%88%8F/%E7%94%9F%E5%91%BD%E6%B8%B8%E6%88%8F%E6%A1%86%E6%9E%B6%E5%BC%80%E5%8F%91-30b19784e45e/

版本迭代：https://pipirima.top/Conway%E7%94%9F%E5%91%BD%E6%B8%B8%E6%88%8F/%E6%B8%B8%E6%88%8F%E4%B8%BB%E7%A8%8B%E5%BA%8F%E5%88%86%E6%9E%90-98a61fc47187/