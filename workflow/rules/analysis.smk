
rule plot_bp_on_counts:
    input: 
        bp_summary=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=config["data_location"]),
        counts_file=expand("{sctrip_dir}/{{sample}}/counts/{{sample}}.txt.raw.gz", sctrip_dir=config["data_location"]),
        info_file=expand("{sctrip_dir}/{{sample}}/counts/{{sample}}.info_raw", sctrip_dir=config["data_location"])
    output: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/analysis/plots/counts_bp.pdf", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/plot_bp_on_counts_plot/{{sample}}.log", sctrip_dir=config["data_location"])
    conda: "../envs/bp_on_counts.yaml"
    shell:
        "Rscript workflow/scripts/plotting/bp_on_counts_plot.R {input.bp_summary} {input.counts_file} {input.info_file} {output}"


rule alessia_plot:
    input: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=config["data_location"])
    output: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/analysis/plots/bp_overview.pdf", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/alessia_plot/{{sample}}.log", sctrip_dir=config["data_location"])
    params: 
        ideo_dt=config["ideo_dt"]
    conda: "../envs/alessia_plot.yaml"
    shell:
        "Rscript workflow/scripts/plotting/bp_overview_plot.R {input} {params.ideo_dt} {output}"


rule bp_counts_violin:
    input: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=config["data_location"])
    output: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/analysis/plots/bp_counts_violin.pdf", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/bp_counts_violin/{{sample}}.log", sctrip_dir=config["data_location"])
    params: 
        chr_to_exclude=config["chr_to_exclude"],
        condition_dt=config["condition_dt"]
    conda: "../envs/bp_on_counts.yaml"
    shell:
        "Rscript workflow/scripts/plotting/bp_overview_plot.R {input} {params.chr_to_exclude} {params.condition_dt} {output}"
