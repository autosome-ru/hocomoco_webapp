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
    return '<a href="http://epifactors.autosome.org/genes?search=' + gene_id + '&field=gene_id">EpiFactors</a>';
  };

  HocomocoDB.hgnc_id_link = function(hgnc) {
    return '<a href="https://www.genenames.org/tools/search/#!/?query=hgnc_id:HGNC:' + hgnc + '">' + hgnc + '</a>';
  };


  HocomocoDB.human_gene_name_link = function(gene_name) {
    return '<a href="https://www.genenames.org/tools/search/#!/?query=gene_symbol:' + gene_name + '">' + gene_name + '</a>' +
    '<br/>' + '(<a href="http://www.genecards.org/cgi-bin/carddisp.pl?gene=' + gene_name + '">GeneCards</a>)';
  };

  HocomocoDB.mouse_gene_name_link = function(gene_name) {
    return '<a href="http://www.informatics.jax.org/searchtool/Search.do?query=' + gene_name + '">' + gene_name + '</a>';
  };

  HocomocoDB.mgi_id_link = function(mgi_name) {
    // return '<a href="http://www.informatics.jax.org/searchtool/Search.do?query=MGI:' + mgi_name + '">' + mgi_name + '</a>';
    return '<a href="http://www.informatics.jax.org/marker/MGI:' + mgi_name + '">' + mgi_name + '</a>';
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
//    '.motif_name'      : HocomocoDB.motif_link,
    '.gene_id'         : HocomocoDB.gene_id_link,
    '.AUC'             : HocomocoDB.round,
    '.human_gene_name' : HocomocoDB.human_gene_name_link,
    '.mouse_gene_name' : HocomocoDB.mouse_gene_name_link,
    '.hgnc_id'         : HocomocoDB.hgnc_id_link,
    '.mgi_id'          : HocomocoDB.mgi_id_link,
    '.uniprot_ac'      : HocomocoDB.uniprot_ac_link,
    '.tfclass'         : HocomocoDB.tfclass_link,
    '.motif-family'    : HocomocoDB.tfclass_motif_family_link,
    '.motif-subfamily' : HocomocoDB.tfclass_motif_family_link,
    '.uniprot_ac_and_tfclass' : HocomocoDB.uniprot_ac_and_tfclass_link,
    '.fantom_sstar_gene' : HocomocoDB.fantom_sstar_gene_link,
    '.pmid'            : multiterm( HocomocoDB.pmid_link ),
    '.uniprot_id'      : multiterm( HocomocoDB.uniprot_id_link ),
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
