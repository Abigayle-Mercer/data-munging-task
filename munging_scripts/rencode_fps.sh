# note that the crop here assumes horizontal videos

# pathml

find /data/datasets/PathML_Phase1/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {}  -vf fps=fps=1:0,scale_npp=224:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 5 -preset slow /mnt/ephemeral/fps1/\$(basename {})" {} \;

# amstudy

find /data/datasets/AMstudy/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {} -vf fps=fps=1:0,scale_npp=224:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 5 -preset slow /mnt/ephemeral/fps1/\$(basename {})" {} \;


# act24

find /data/datasets/ACT24study/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {} -vf fps=fps=1:0,scale_npp=224:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 5 -preset slow /mnt/ephemeral/fps1/\$(basename {})" {} \;

### fps=2


find /data/datasets/PathML_Phase1/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {}  -vf fps=fps=2:0,scale_npp=224:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 8 -preset slow /mnt/ephemeral/fps2/\$(basename {})" {} \;

# amstudy

find /data/datasets/AMstudy/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {} -vf fps=fps=2:0,scale_npp=224:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 8 -preset slow /mnt/ephemeral/fps2/\$(basename {})" {} \;


# act24

find /data/datasets/ACT24study/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {} -vf fps=fps=2:0,scale_npp=224:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 8 -preset slow /mnt/ephemeral/fps2/\$(basename {})" {} \;


### fps=2,384x384


find /data/datasets/PathML_Phase1/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {}  -vf fps=fps=2:0,scale_npp=384:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 8 -preset slow /mnt/ephemeral/fps2_384/\$(basename {})" {} \;

# amstudy

find /data/datasets/AMstudy/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {} -vf fps=fps=2:0,scale_npp=384:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 8 -preset slow /mnt/ephemeral/fps2_384/\$(basename {})" {} \;


# act24

find /data/datasets/ACT24study/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {} -vf fps=fps=2:0,scale_npp=384:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 8 -preset slow /mnt/ephemeral/fps2_384/\$(basename {})" {} \;

# wisc

find /data/datasets/Wisconsin/ -name '*.mp4' -exec bash -c "docker run --rm --runtime=nvidia -v /data:/data -v /mnt/ephemeral:/mnt/ephemeral jrottenberg/ffmpeg:5.1-nvidia2004 -hwaccel cuvid -hwaccel_output_format cuda -c:v h264_cuvid -y -crop 0x0x140x140 -i {} -vf fps=fps=2:0,scale_npp=384:-1:force_original_aspect_ratio=decrease -c:v h264_nvenc -g 8 -preset slow /mnt/ephemeral/fps2_384/\$(basename {})" {} \;
