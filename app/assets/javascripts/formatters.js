;(function(HocomocoDB, $, undefined) {

  // (from https://stackoverflow.com/a/901144/10712892)
  function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
  }

  HocomocoDB.gene_id_link = function(gene_id) {
    return '<a href="https://www.ncbi.nlm.nih.gov/gene/' + gene_id + '" target="_blank">' + gene_id + '</a>' +
    '<br/>(' + HocomocoDB.fantom_sstar_gene_link(gene_id) + ')'/*; +
    '<br/>(' + HocomocoDB.epifactors_link(gene_id) + ')'*/; // We need to check whether such epifactor exists

  };

  HocomocoDB.fantom_sstar_gene_link = function(gene_id) {
    return '<a href="https://fantom.gsc.riken.jp/5/sstar/EntrezGene:' + gene_id + '" target="_blank">SSTAR</a>';
  };

  HocomocoDB.epifactors_link = function(gene_id) {
    return '<a href="https://epifactors.autosome.org/genes?search=' + gene_id + '&field=gene_id" target="_blank">EpiFactors</a>';
  };

  HocomocoDB.hgnc_id_link = function(hgnc) {
    return '<a href="https://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=' + hgnc + '" target="_blank">' + hgnc + '</a>';
  };


  HocomocoDB.mgi_id_link = function(mgi_name) {
    return '<a href="https://www.informatics.jax.org/marker/MGI:' + mgi_name + '" target="_blank">' + mgi_name + '</a>';
  };

  HocomocoDB.uniprot_id_link = function(uniprot_id) {
    return '<a href="https://www.uniprot.org/uniprot/' + uniprot_id +'" target="_blank">' + uniprot_id + '</a>';
  };

  HocomocoDB.tfclass_uniprot_link = function(uniprot_ac, title) {
    if (title === undefined) { title = 'TFClass'; }
    return '<a href="http://tfclass.bioinf.med.uni-goettingen.de/?uniprot=' + uniprot_ac + '" target="_blank">' + title + '</a>';
  };

  HocomocoDB.uniprot_ac_link = function(uniprot_ac) {
    return '<a href="https://www.uniprot.org/uniprot/' + uniprot_ac + '" target="_blank">' + uniprot_ac + '</a>';
  };

  HocomocoDB.motif_link = function(motif_and_optional_comment) {
    var infos = motif_and_optional_comment.split(/\s+/);
    var motif = infos[0];
    var motif_link = '<a href="' + HocomocoDB.app_prefix + 'motif/' + motif + '" target="_blank">' + motif + '</a>';
    if (infos.length <= 1) {
      return motif_link;
    } else {
      return motif_link + ' ' + '<span style="color:red;">' + infos[1] + '</span>';
    }
  };

  HocomocoDB.round = function(value) {
    return value != '' ? Number(value).toFixed(3) : '';
  }

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
    '.gene_id'         : HocomocoDB.gene_id_link,
    '.AUC'             : HocomocoDB.round,
    '.hgnc_id'         : HocomocoDB.hgnc_id_link,
    '.mgi_id'          : HocomocoDB.mgi_id_link,
    '.uniprot_ac'      : HocomocoDB.uniprot_ac_link,
    '.fantom_sstar_gene' : HocomocoDB.fantom_sstar_gene_link,
    '.uniprot_id'      : multiterm( HocomocoDB.uniprot_id_link ),
  };

  HocomocoDB.preserveFormatters = { // What to save in cell textAttribute (for CSV output and search facilities)
  };

  HocomocoDB.tablesorter_formatters = make_tablesorter_formatters(HocomocoDB.formatters, HocomocoDB.preserveFormatters);

})(window.HocomocoDB = window.HocomocoDB || {}, jQuery);
