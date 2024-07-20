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
    return '<a href="https://www.genenames.org/tools/search/#!/?query=hgnc_id:HGNC:' + hgnc + '" target="_blank">' + hgnc + '</a>';
  };


  HocomocoDB.gene_name_link = function(gene_species_name) {
    let species   = gene_species_name.split(':')[0];
    let gene_name = gene_species_name.split(':')[1];
    if (species == 'HUMAN') {
      return HocomocoDB.human_gene_name_link(gene_name);
    } else if (species == 'MOUSE') {
      return HocomocoDB.mouse_gene_name_link(gene_name);
    } else {
      return gene_species_name;
    }
  };

  HocomocoDB.human_gene_name_link = function(gene_name) {
    return '<a href="https://www.genenames.org/tools/search/#!/?query=gene_symbol:' + gene_name + '" target="_blank">' + gene_name + '</a>' +
    '<br/>' + '(<a href="https://www.genecards.org/cgi-bin/carddisp.pl?gene=' + gene_name + '" target="_blank">GeneCards</a>)';
  };

  HocomocoDB.mouse_gene_name_link = function(gene_name) {
    return '<a href="https://www.informatics.jax.org/marker/summary?nomen=' + gene_name + '" target="_blank">' + gene_name + '</a>';
  };

  HocomocoDB.mgi_id_link = function(mgi_name) {
    // return '<a href="https://www.informatics.jax.org/searchtool/Search.do?query=MGI:' + mgi_name + '" target="_blank">' + mgi_name + '</a>';
    return '<a href="https://www.informatics.jax.org/marker/MGI:' + mgi_name + '" target="_blank">' + mgi_name + '</a>';
  };

  HocomocoDB.uniprot_id_link = function(uniprot_id) {
    return '<a href="https://www.uniprot.org/uniprot/' + uniprot_id +'" target="_blank">' + uniprot_id + '</a>';
  };

  HocomocoDB.tfclass_uniprot_link = function(uniprot_ac, title) {
    if (title === undefined) { title = 'TFClass'; }
    return '<a href="http://tfclass.bioinf.med.uni-goettingen.de/?uniprot=' + uniprot_ac + '" target="_blank">' + title + '</a>';
  };

  HocomocoDB.tfclass_family_link = function(family_id, title) {
    if (title === undefined) { title = 'TFClass'; }
    return '<a href="http://tfclass.bioinf.med.uni-goettingen.de/?tfclass=' + family_id + '" target="_blank">' + title + '</a>';
  };

  HocomocoDB.tfclass_motif_family_link = function(string) {
    var motif_family_id = string.match(/\{(.+?)\}/);
    if (motif_family_id && motif_family_id[1]) {
      var familySearchURL = '/search?family_id=' + motif_family_id[1];
      if (getParameterByName('arity')) {
        familySearchURL += '&arity=' + getParameterByName('arity')
      }
      if (getParameterByName('species')) {
        familySearchURL += '&species=' + getParameterByName('species')
      }
      return string.replace(/\{.+?\}/, ' {<a href="' + familySearchURL + '">' + motif_family_id[1] + '</a>}') +
             ' (' + HocomocoDB.tfclass_family_link(motif_family_id[1], 'TFClass') + ')';
    } else {
      return string
    }
  };

  HocomocoDB.uniprot_ac_link = function(uniprot_ac) {
    return '<a href="https://www.uniprot.org/uniprot/' + uniprot_ac + '" target="_blank">' + uniprot_ac + '</a>';
  };

  HocomocoDB.uniprot_ac_and_tfclass_link = function(uniprot_ac) {
    return HocomocoDB.uniprot_ac_link(uniprot_ac) + '<br/>' + '(' + HocomocoDB.tfclass_uniprot_link(uniprot_ac) + ')';
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
    '.gene_name'       : multiterm(HocomocoDB.gene_name_link, '<br/>', '; '),
    '.human_gene_name' : multiterm(HocomocoDB.human_gene_name_link, '<br/>', '; '),
    '.mouse_gene_name' : multiterm(HocomocoDB.mouse_gene_name_link, '<br/>', '; '),
    '.hgnc_id'         : HocomocoDB.hgnc_id_link,
    '.mgi_id'          : HocomocoDB.mgi_id_link,
    '.uniprot_ac'      : HocomocoDB.uniprot_ac_link,
    '.tfclass'         : HocomocoDB.tfclass_link,
    '.motif-family'    : multiterm(HocomocoDB.tfclass_motif_family_link, '<br/>', '; '),
    '.motif-subfamily' : multiterm(HocomocoDB.tfclass_motif_family_link, '<br/>', '; '),
    '.uniprot_ac_and_tfclass' : HocomocoDB.uniprot_ac_and_tfclass_link,
    '.fantom_sstar_gene' : HocomocoDB.fantom_sstar_gene_link,
    '.uniprot_id'      : multiterm( HocomocoDB.uniprot_id_link ),
  };

  HocomocoDB.preserveFormatters = { // What to save in cell textAttribute (for CSV output and search facilities)
  };

  HocomocoDB.tablesorter_formatters = make_tablesorter_formatters(HocomocoDB.formatters, HocomocoDB.preserveFormatters);

})(window.HocomocoDB = window.HocomocoDB || {}, jQuery);
