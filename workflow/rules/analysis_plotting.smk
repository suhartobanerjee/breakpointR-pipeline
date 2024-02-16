
rule plot_bp_on_counts:
    input: 
        bp_summary=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=config["data_location"]),
        counts_file=expand("{sctrip_dir}/{{sample}}/counts/{{sample}}.txt.raw.gz", sctrip_dir=config["data_location"]),
        info_file=expand("{sctrip_dir}/{{sample}}/counts/{{sample}}.info_raw", sctrip_dir=config["data_location"]),
        species_name=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/species/species_name.txt", sctrip_dir=config["data_location"])
    output: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/analysis/plots/{{sample}}_counts_bp.pdf", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/plot_bp_on_counts_plot/{{sample}}.log", sctrip_dir=config["data_location"])
    conda: "../envs/bp_on_counts.yaml"
    shell:
        "Rscript workflow/scripts/plotting/bp_on_counts_plot.R {input.bp_summary} {input.counts_file} {input.info_file} {input.species_name} {output}"


rule bp_overview:
    input: 
        bp_summary=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=config["data_location"]),
        chr_len=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/species/chr_len.tsv", sctrip_dir=config["data_location"])
    output: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/analysis/plots/{{sample}}_bp_overview.pdf", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/alessia_plot/{{sample}}.log", sctrip_dir=config["data_location"])
    conda: "../envs/alessia_plot.yaml"
    shell:
        "Rscript workflow/scripts/plotting/bp_overview_plot.R {input.bp_summary} {input.chr_len} {output}"


rule bp_counts_violin:
    input: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=config["data_location"])
    output: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/analysis/plots/{{sample}}_bp_counts_violin.pdf", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/bp_counts_violin/{{sample}}.log", sctrip_dir=config["data_location"])
    params: 
        chr_to_exclude=config["chr_to_exclude"] if config["chr_to_exclude"] != "" else '""',
        condition_dt=config["condition_dt"] if config["condition_dt"] != "" else '""'
    conda: "../envs/bp_on_counts.yaml"
    shell:
        """
        Rscript workflow/scripts/plotting/bp_counts_violin.R {input} {params.chr_to_exclude} {params.condition_dt} {output}
        """

rule bp_counts_chr_violin:
    input: 
        bp_summary=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=config["data_location"]),
        chr_len=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/species/chr_len.tsv", sctrip_dir=config["data_location"])
    output: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/analysis/plots/{{sample}}_bp_counts_chr_violin.pdf", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/bp_counts_violin/{{sample}}.log", sctrip_dir=config["data_location"])
    params: 
        chr_to_exclude=config["chr_to_exclude"] if config["chr_to_exclude"] != "" else '""',
        condition_dt=config["condition_dt"] if config["condition_dt"] != "" else '""'
    conda: "../envs/bp_on_counts.yaml"
    shell:
        """
        Rscript workflow/scripts/plotting/bp_counts_chr_violin.R {input.bp_summary} {params.chr_to_exclude} {params.condition_dt} {input.chr_len} {output}
        """

