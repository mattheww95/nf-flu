process PULL_TOP_REF_ID {
  tag "$meta.id"
  label 'process_medium'

  conda (params.enable_conda ? 'conda-forge::python=3.9 conda-forge::biopython=1.78 conda-forge::openpyxl=3.0.7 conda-forge::pandas=1.2.4 conda-forge::rich=10.2.2 conda-forge::typer=0.3.2 conda-forge::xlsxwriter=1.4.3' : null)
  if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
    container 'https://depot.galaxyproject.org/singularity/mulled-v2-693e24f156d01a5f55647120be99929b01b30949:609c862c3470382215fc1b2d9d8a4e9637b2e25f-0'
  } else {
    container 'quay.io/biocontainers/mulled-v2-693e24f156d01a5f55647120be99929b01b30949:609c862c3470382215fc1b2d9d8a4e9637b2e25f-0'
  }

  input:
  tuple val(meta), path(blastn_results)
  path(genomeset)

  output:
  tuple val(meta), path("*.csv"), optional: true, emit: accession_id
  path "versions.yml", emit: versions

  script:
  """
  parse_influenza_blast_results.py \\
    --threads ${task.cpus} \\
    --flu-metadata $genomeset \\
    --get-top-ref True \\
    --top 1 \\
    --pident-threshold $params.pident_threshold \\
    --sample-name ${meta.id} \\
    $blastn_results

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
     python: \$(python --version | sed 's/Python //g')
  END_VERSIONS
  """
}
