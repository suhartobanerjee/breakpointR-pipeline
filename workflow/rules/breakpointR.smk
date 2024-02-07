rule check_species_chr_len:
    input: expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/selected_bam", sctrip_dir=config["data_location"])
    output: 
        species_name=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/species/species_name.txt", sctrip_dir=config["data_location"]),
        chr_len=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/species/chr_len.tsv", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/check_species/{{sample}}.log", sctrip_dir=config["data_location"])
    conda: "../envs/alignmentenv.yaml"
    shell:
        "workflow/scripts/select_bam/check_species.sh {input} {output.species_name} {output.chr_len}"



rule run_breakpointR:
    input: 
        bam_dir=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/selected_bam", sctrip_dir=config["data_location"]),
        species_name=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/species/species_name.txt", sctrip_dir=config["data_location"]),
    output: 
        out_dir=directory(expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output", sctrip_dir=config["data_location"])),
        bp_summary=expand("{sctrip_dir}/breakpointR-pipeline/{{sample}}/breakpointR_output/breakpoints/breakPointSummary.txt", sctrip_dir=config["data_location"])
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/run_breakpointR/{{sample}}.log", sctrip_dir=config["data_location"])
    conda: "../envs/breakpointR.yaml"
    shell:
        """
        Rscript workflow/scripts/breakpointR_run/breakpointR_exec.R \
            {input.bam_dir} \
            {output.out_dir} \
            {config[pairedEndReads]} \
            {resources.threads} \
            {config[minReads]} \
            {config[maskRegions]} \
            {config[reuse_existing_files]} \
            {config[windowsize]} \
            {config[background]} \
            {config[binMethod]} \
            {config[pair2frgm]} \
            {config[min_mapq]} \
            {config[callHotSpots]} \
            {config[filtAlt]} \
            {input.species_name}
        """


