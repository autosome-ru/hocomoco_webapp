;(function(HocomocoDB, $, undefined) {

  HocomocoDB.gene_id_link = function(gene_id) {
    return '<a href="http://www.ncbi.nlm.nih.gov/gene/' + gene_id + '">' + gene_id + '</a>' +
    '<br/>(' + HocomocoDB.fantom_sstar_gene_link(gene_id) + ')'/*; +
    '<br/>(' + HocomocoDB.epifactors_link(gene_id) + ')'*/; // We need to check whether such epifactor exists

  };

  HocomocoDB.fantom_sstar_gene_link = function(gene_id) {
    return '<a href="http://fantom.gsc.riken.jp/5/sstar/EntrezGene:' + gene_id + '">SSTAR</a>';
  };

  HocomocoDB.epifactors_link = function(gene_id) {
    return '<a href="http://epifactors.autosome.ru/genes?search=' + gene_id + '&field=gene_id">EpiFactors</a>';
  };

  HocomocoDB.hgnc_id_link = function(hgnc) {
    return '<a href="http://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=' + hgnc + '">' + hgnc + '</a>';
  };


  HocomocoDB.human_gene_name_link = function(gene_name) {
    return '<a href="http://www.genenames.org/cgi-bin/gene_symbol_report?match=' + gene_name + '">' + gene_name + '</a>' +
    '<br/>' + '(<a href="http://www.genecards.org/cgi-bin/carddisp.pl?gene=' + gene_name + '">GeneCards</a>)';
  };

  HocomocoDB.mouse_gene_name_link = function(gene_name) {
    return '<a href="http://www.informatics.jax.org/searchtool/Search.do?query=' + gene_name + '">' + gene_name + '</a>';
  };

  HocomocoDB.mgi_id_link = function(mgi_name) {
    // return '<a href="http://www.informatics.jax.org/searchtool/Search.do?query=MGI:' + mgi_name + '">' + mgi_name + '</a>';
    return '<a href="http://www.informatics.jax.org/marker/MGI:' + mgi_name + '">' + mgi_name + '</a>';
  };

  // genename_with_id is `SMARCA4#561` -- a SMARCA4 gene with id 561.
  HocomocoDB.HocomocoDB_gene_link = function(genename_with_id) {
    var gene_name, gene_id,
        match = /^(.+)#(\d+)$/.exec(genename_with_id);
    if (!match) { return genename_with_id; }
    gene_name = match[1];
    gene_id = match[2];
    return '<a href="' + HocomocoDB.app_prefix + 'genes/' + gene_id +'">' + gene_name + '</a>';
  };

  // genename_with_id is `SMARCA4#561` -- a SMARCA4 gene with id 561.
  HocomocoDB.HocomocoDB_gene_name_only = function(genename_with_id) {
    var match = /^(.+)#(\d+)$/.exec(genename_with_id);
    if (!match) { return genename_with_id; }
    return match[1];
  };

  HocomocoDB.uniprot_id_link = function(uniprot_id) {
    return '<a href="http://www.uniprot.org/uniprot/' + uniprot_id +'">' + uniprot_id + '</a>';
  };

  // identifier can be UniprotAC or TFClass index
  HocomocoDB.tfclass_link = function(identifier, name) {
    if (name === undefined) { name = 'TFClass'; }
    return '<a href="http://tfclass.bioinf.med.uni-goettingen.de/tfclass?uniprot=' + identifier + '">' + name + '</a>';
  };

  HocomocoDB.tfclass_motif_family_link = function(string) {
    var motif_family_id = string.match(/\{(.+?)\}/);
    if (motif_family_id && motif_family_id[1]) {
      return string.replace(/\{.+?\}/, '{' + HocomocoDB.tfclass_link(motif_family_id[1], motif_family_id[1]) + '}');
    } else {
      return string
    }
  };

  HocomocoDB.uniprot_ac_link = function(uniprot_ac) {
    return '<a href="http://www.uniprot.org/uniprot/' + uniprot_ac + '">' + uniprot_ac + '</a>';
  };

  HocomocoDB.uniprot_ac_and_tfclass_link = function(uniprot_ac) {
    return HocomocoDB.uniprot_ac_link(uniprot_ac) + '<br/>' + '(' + HocomocoDB.tfclass_link(uniprot_ac) + ')';
  };

  HocomocoDB.refseq_link = function(refseq) {
    return '<a href="http://www.ncbi.nlm.nih.gov/nucleotide/' + refseq + '">' + refseq + '</a>';
  };

  HocomocoDB.motif_link = function(motif_and_optional_comment) {
    var infos = motif_and_optional_comment.split(/\s+/);
    var motif = infos[0];
    var motif_link = '<a href="' + HocomocoDB.app_prefix + 'motif/' + motif + '">' + motif + '</a>';
    if (infos.length <= 1) {
      return motif_link;
    } else {
      return motif_link + ' ' + '<span style="color:red;">' + infos[1] + '</span>';
    }
  };

  HocomocoDB.pmid_link = function(pmid) {
    if (isNaN(pmid)) {
      return pmid; // Some PMIDs look like "Uniprot", "by similarity" and "Uniprot (by similarity)"
    } else {
      return '<a href="http://www.ncbi.nlm.nih.gov/pubmed/' + pmid + '">' + pmid + '</a>';
    }
  };

  HocomocoDB.target_complex_link = function(target) {
    return '<a href="' + HocomocoDB.app_prefix + 'protein_complexes?search=' + target + '&field=complex_name">' + target + '</a>';
  };

  HocomocoDB.pfam_domain_link = function(pfam_info) {
    var infos = $.trim(pfam_info).split(/\s+/);
    return '<a href="http://pfam.xfam.org/family/' + infos[1] + '">' + infos.slice(0, 2).join('&nbsp;') + '</a> (' + infos.slice(2).join(', ') + ')';
  };

  HocomocoDB.expression_bar = function(value, data) {
    var tbodyIndex      = data.config.$tbodies.index( data.$cell.parents('tbody').filter(':first') ),
        max_expression  = data.config.cache[tbodyIndex].colMax[data.columnIndex],
        percentage      = 100.0 * value / max_expression;
    return Number(value).toFixed(1) + '<div class="expression-bar" style="width:' + percentage + '%;">' + '</div>';
  };

  HocomocoDB.quantile = function(value, data) {
    return Number(value).toFixed(4);
  }

  HocomocoDB.round = function(value) {
    return value != '' ? Number(value).toFixed(3) : '';
  }

  HocomocoDB.sample_link = function(value, data) {
    var match, name, library_id, extract_name, sample_format, url;
    match = /^(.+)\.(CNhs\w+)\.(\w+-\w+)?$/.exec(value);
    name = match[1];
    library_id = match[2];
    extract_name = match[3];
    sample_format = data.$header && data.$header.data('sample-format');
    url = HocomocoDB.app_prefix + 'samples/' + library_id;
    fantom_sstar_url = 'http://fantom.gsc.riken.jp/5/sstar/FF:' + extract_name;
    if (!sample_format || sample_format == 'short') {
      return '<a href="' + url + '"">' + name + '</a> <span class="fantom-external-link">(<a href="' + fantom_sstar_url + '">FANTOM5 SSTAR</a>)</span>';
    } else if (sample_format == 'full') {
      return '<a href="' + url + '">' + value + '</a> <span class="fantom-external-link">(<a href="' + fantom_sstar_url + '">FANTOM5 SSTAR</a>)</span>';
    } else {
      return value;
    }
  };

  HocomocoDB.ec_number_link = function(ec) {
    var ec_parts = ec.split('.');
    var ec_query = [];
    $.each(ec_parts, function(ec_part_index, ec_part) {
      if (Number(ec_part)) {
        ec_query.push('field' + (1 + ec_part_index) + '=' + ec_part);
      }
    });
    if (ec_query.length > 0) {
      return '<a href="http://enzyme.expasy.org/cgi-bin/enzyme/enzyme-search-ec?' + ec_query.join('&') + '">' + ec + '</a>';
    } else {
      return ec;
    }
  };

  var multiterm,
      formatter_preserving_text,
      make_tablesorter_formatters;

  multiterm = function(apply_func, joining_sequence, splitter_pattern) {
    if (typeof(splitter_pattern)==='undefined') splitter_pattern = ', ';
    if (typeof(joining_sequence)==='undefined') joining_sequence = ', ';
    return function(multiple_ids) {
      var terms = multiple_ids.split(splitter_pattern);
      terms = $.map(terms, $.trim);
      return $.map(terms, apply_func).join(joining_sequence)
    };
  };

  formatter_preserving_text = function(formatter, preservedTextFormatter) {
    return function(text, data) {
      var preservedText = $.isFunction(preservedTextFormatter) ? preservedTextFormatter(text, data) : text;
      if (!data.$cell.attr(data.config.textAttribute)) {
        data.$cell.attr(data.config.textAttribute, preservedText);
      }
      return formatter(text, data);
    };
  };

  formatter_ignoring_sharp = function(formatter) {
    return function(text, data) {
      if (text == '#') {
        return '#';
      } else {
        return formatter(text, data);
      }
    };
  }

  make_tablesorter_formatters = function(formatters, preserveFormatters) {
    var result = {},
        selector;
    for (selector in formatters) {
      result[selector] = formatter_ignoring_sharp(
                            formatter_preserving_text(
                                formatters[selector],
                                preserveFormatters[selector]
                            )
                          );
    }
    return result;
  };

  HocomocoDB.formatters = {
//    '.motif_name'      : HocomocoDB.motif_link,
    '.gene_id'         : HocomocoDB.gene_id_link,
    '.AUC'             : HocomocoDB.round,
    '.ec_number'       : HocomocoDB.ec_number_link,
    '.human_gene_name' : HocomocoDB.human_gene_name_link,
    '.mouse_gene_name' : HocomocoDB.mouse_gene_name_link,
    '.hgnc_id'         : HocomocoDB.hgnc_id_link,
    '.mgi_id'          : HocomocoDB.mgi_id_link,
    '.uniprot_ac'      : HocomocoDB.uniprot_ac_link,
    '.tfclass'         : HocomocoDB.tfclass_link,
    '.motif-family'    : HocomocoDB.tfclass_motif_family_link,
    '.motif-subfamily' : HocomocoDB.tfclass_motif_family_link,
    '.uniprot_ac_and_tfclass' : HocomocoDB.uniprot_ac_and_tfclass_link,
    '.refseq'          : HocomocoDB.refseq_link,
    '.expression_bar'  : HocomocoDB.expression_bar,
    '.quantile'        : HocomocoDB.quantile,
    '.sample_link'     : HocomocoDB.sample_link,
    '.fantom_sstar_gene' : HocomocoDB.fantom_sstar_gene_link,
    '.pmid'            : multiterm( HocomocoDB.pmid_link ),
    '.target_complex'  : multiterm( HocomocoDB.target_complex_link),
    '.uniprot_id'      : multiterm( HocomocoDB.uniprot_id_link ),
    '.pfam_domain'     : multiterm( HocomocoDB.pfam_domain_link, '<br/>' ),
  };

  HocomocoDB.preserveFormatters = { // What to save in cell textAttribute (for CSV output and search facilities)
  };

  HocomocoDB.tablesorter_formatters = make_tablesorter_formatters(HocomocoDB.formatters, HocomocoDB.preserveFormatters);

  // apply formatters outside of tablesorter
  HocomocoDB.apply_formatters = function(jquery_selector) {
    var selector, formatter;
    for (selector in HocomocoDB.formatters) {
      formatter = formatter_ignoring_sharp(HocomocoDB.formatters[selector]);

      $(jquery_selector).filter(selector).each(function(ind, elem) {
        var data = { // mimic table cell
          $cell: $(elem).eq(0),
        };
        window.dat = data;
        $(elem).html( formatter($(elem).text(), data) );
      });
    };
  };

})(window.HocomocoDB = window.HocomocoDB || {}, jQuery);
