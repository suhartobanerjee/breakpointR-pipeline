
rule plot_bp_on_counts:
    input: 
        bp_summary=expand("{sctrip_dir}/breakpointR-pipeline/{sample}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=SCTRIP_DIR, sample=SAMPLES),
        counts_file=expand("{sctrip_dir}/{sample}/counts/{sample}.txt.gz", sctrip_dir=SCTRIP_DIR, sample=SAMPLES),
        info_file=expand("{sctrip_dir}/{sample}/counts/{sample}.info", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
    output: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/analysis/plots/counts_bp.pdf", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/plot_bp_on_counts_plot.log", sctrip_dir=SCTRIP_DIR)
    conda: "rda"
    shell:
        "Rscript workflow/scripts/plotting/bp_on_counts_plot.R {input.bp_summary} {input.counts_file} {input.info_file} {output}"


rule alessia_plot:
    input: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
    output: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/analysis/plots/bp_overview.pdf", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/plot_bp_on_counts_plot.log", sctrip_dir=SCTRIP_DIR)
    params: 
        ideo_dt=config["ideo_dt"]
    conda: "../envs/alessia_plot.yaml"
    shell:
        "Rscript workflow/scripts/plotting/bp_overview_plot.R {input} {params.ideo_dt} {output}"
