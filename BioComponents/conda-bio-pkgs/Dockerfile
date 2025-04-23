# 基于biocontainers的基础镜像
FROM biocontainers/biocontainers:v1.2.0_cv1

# 安装必要的工具和依赖项
RUN conda install -c bioconda \
    python=3.7 \
    r-base \
    r-seurat \
    fastqc \
    multiqc \
    star \
    && conda clean -a -y


# 运行示例脚本（可选）
# CMD ["./run_pipeline.sh"]
