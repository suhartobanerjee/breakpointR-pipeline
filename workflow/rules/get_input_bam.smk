#rule check_copy_selected_bams:
#    input: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/selected_bam/labels.tsv", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
#    output: expand("{sctrip_dir}/breakpointR-pipeline/{sample}/checks/check_copy_selected_bams.ok", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
#    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/check_copy_selected_bams.log", sctrip_dir=SCTRIP_DIR)
#    shell:
#        """
#        workflow/scripts/select_bam/check_copy_selected_bams.sh {input} > {log} 2>&1
#        if [ $? -eq 0 ]; then
#            touch {output}
#        else
#            echo "bam files were not faithfully copied"
#            exit 1
#        fi
#        """


rule copy_selected_bams:
    input: 
        cell_list=expand("{sctrip_dir}/{sample}/cell_selection/labels.tsv", sctrip_dir=SCTRIP_DIR, sample=SAMPLES),
        bam_dir=expand("{sctrip_dir}/{sample}/bam", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)
    output: 
        selected_bam=directory(expand("{sctrip_dir}/breakpointR-pipeline/{sample}/selected_bam", sctrip_dir=SCTRIP_DIR, sample=SAMPLES)),
        labels_tsv=expand("{sctrip_dir}/breakpointR-pipeline/{sample}/selected_bam/labels.tsv", sctrip_dir=SCTRIP_DIR, sample=SAMPLES),
    log: expand("{sctrip_dir}/breakpointR-pipeline/logs/copy_selected_bams.log", sctrip_dir=SCTRIP_DIR)
    threads: 16
    shell: 
        "workflow/scripts/select_bam/copy_selected_bams.sh {input.cell_list} {input.bam_dir} {output.selected_bam} > {log} 2>&1"
