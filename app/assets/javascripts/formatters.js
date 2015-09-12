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


  HocomocoDB.hgnc_name_link = function(hgnc_name) {
    return '<a href="http://www.genenames.org/cgi-bin/gene_symbol_report?match=' + hgnc_name + '">' + hgnc_name + '</a>' +
    '<br/>' + '(<a href="http://www.genecards.org/cgi-bin/carddisp.pl?gene=' + hgnc_name + '">GeneCards</a>)';

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
    return '<a href="/genes/' + gene_id +'">' + gene_name + '</a>';
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

  HocomocoDB.uniprot_ac_link = function(uniprot_ac) {
    return '<a href="http://www.uniprot.org/uniprot/' + uniprot_ac + '">' + uniprot_ac + '</a>' +
    '<br/>' + '<a href="http://tfclass.bioinf.med.uni-goettingen.de/tfclass?uniprot=' + uniprot_ac + '">(TFClass)</a>';
  };

  HocomocoDB.refseq_link = function(refseq) {
    return '<a href="http://www.ncbi.nlm.nih.gov/nucleotide/' + refseq + '">' + refseq + '</a>';
  };

  HocomocoDB.pmid_link = function(pmid) {
    if (isNaN(pmid)) {
      return pmid; // Some PMIDs look like "Uniprot", "by similarity" and "Uniprot (by similarity)"
    } else {
      return '<a href="http://www.ncbi.nlm.nih.gov/pubmed/' + pmid + '">' + pmid + '</a>';
    }
  };

  HocomocoDB.target_complex_link = function(target) {
    return '<a href="/protein_complexes?search=' + target + '&field=complex_name">' + target + '</a>';
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
    url = '/samples/' + library_id;
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

  HocomocoDB.hocomoco_link = function(value) {
    if (value == '') {
      return '';
    }
    var parts = value.split('_');
    var tf = parts[0];
    var model = parts[1];
    var img_html = '<img src="http://autosome.ru/HOCOMOCO/logos/thumbs/' + value + '_thumb.jpg">';
    var link_html = '<a href="http://autosome.ru/HOCOMOCO/modelDetails.php?tf=' + tf + '&model=' + model + '">' +
                    value + img_html +
                    '</a>';
    return '<div class="hocomoco_link">' + link_html + '</div>';
  };

  HocomocoDB.comb_span_wrappers = {
    term:               ['<span class="comb_term">',                '</span>'],
    multiple:           ['<span class="comb_multiple">',            '+</span>'],
    optional:           ['<span class="comb_optional">',            '?</span>'],
    alternative:        ['<span class="comb_alternative">',         '</span>'],
    alternative_group:  ['<span class="comb_alternative_group">(',  ')</span>'],
    comb:               ['<span class="comb">',                     '</span>'],
    join_alternatives:  ' | ',
    join_enumeration:   ', ',
  };

  HocomocoDB.comb_plain_wrappers = {
    term:               ['',  ''],
    multiple:           ['',  '+'],
    optional:           ['',  '?'],
    alternative:        ['',  ''],
    alternative_group:  ['(', ')'],
    comb:               ['',  ''],
    join_alternatives:  '|',
    join_enumeration:   ', ',
  };

  var markup_comb_alternatives,
      markup_comb_term,
      multiterm,
      formatter_preserving_text,
      make_tablesorter_formatters;

  // 'abc|def' --> '<div class="alternative_uniprot">abc</div><div class="alternative_uniprot">def</div>']
  markup_comb_alternatives = function(comb_part, term_formatter, wrappers) {
    var tokens = comb_part.split('|');
    return $.map(tokens, function(token) {
      return wrappers.alternative[0] + markup_comb_term($.trim(token), term_formatter, wrappers) + wrappers.alternative[1];
    }).join(wrappers.join_alternatives);
  };

  markup_comb_term = function(term, term_formatter, wrappers) {
    if (term.slice(-1) == '+') {
      return wrappers.multiple[0] + markup_comb_term(term.slice(0, -1), term_formatter, wrappers) + wrappers.multiple[1];
    } else if (term.slice(-1) == '?') {
      return wrappers.optional[0] + markup_comb_term(term.slice(0, -1), term_formatter, wrappers) + wrappers.optional[1];
    } else if (term.slice(0, 1) == '(' && term.slice(-1) == ')') {
      return wrappers.alternative_group[0] + markup_comb_alternatives(term.slice(1, -1), term_formatter, wrappers) + wrappers.alternative_group[1];
    } else {
      return wrappers.term[0] + term_formatter(term) + wrappers.term[1];
    }
  };

  HocomocoDB.markup_comb = function(comb, term_formatter, wrappers) {
    var tokens = comb.split(',');

    tokens = $.map(tokens, $.trim);
    return wrappers.comb[0] + $.map(tokens, function(term){
      return markup_comb_term(term, term_formatter, wrappers);
    }).join(wrappers.join_enumeration) + wrappers.comb[1];
  };

  HocomocoDB.uniprot_comb_link = function(txt, data) {
    return HocomocoDB.markup_comb(txt, HocomocoDB.uniprot_id_link, HocomocoDB.comb_span_wrappers);
  }

  HocomocoDB.gene_comb_link = function(txt, data) {
    return HocomocoDB.markup_comb(txt, function(txt) { return HocomocoDB.HocomocoDB_gene_link(txt); }, HocomocoDB.comb_span_wrappers);
  }
  HocomocoDB.gene_comb_names_only = function(txt, data) {
    return HocomocoDB.markup_comb(txt, HocomocoDB.HocomocoDB_gene_name_only, HocomocoDB.comb_plain_wrappers);
  }

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
    '.ec_number'       : HocomocoDB.ec_number_link,
    '.hgnc_name'       : HocomocoDB.hgnc_name_link,
    '.hgnc_id'         : HocomocoDB.hgnc_id_link,
    '.mgi_id'          : HocomocoDB.mgi_id_link,
    '.uniprot_ac'      : HocomocoDB.uniprot_ac_link,
    '.refseq'          : HocomocoDB.refseq_link,
    '.uniprot_id_comb' : HocomocoDB.uniprot_comb_link,
    '.gene_comb'       : HocomocoDB.gene_comb_link,
    '.expression_bar'  : HocomocoDB.expression_bar,
    '.quantile'        : HocomocoDB.quantile,
    '.sample_link'     : HocomocoDB.sample_link,
    '.fantom_sstar_gene' : HocomocoDB.fantom_sstar_gene_link,
    '.pmid'            : multiterm( HocomocoDB.pmid_link ),
    '.target_complex'  : multiterm( HocomocoDB.target_complex_link),
    '.uniprot_id'      : multiterm( HocomocoDB.uniprot_id_link ),
    '.pfam_domain'     : multiterm( HocomocoDB.pfam_domain_link, '<br/>' ),
    '.hocomoco'        : multiterm( HocomocoDB.hocomoco_link, '' ), // hocomoco links with motif logos go on different lines, comma is unnecessary
  };

  HocomocoDB.preserveFormatters = { // What to save in cell textAttribute (for CSV output and search facilities)
    '.gene_comb'       : HocomocoDB.gene_comb_names_only,
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
