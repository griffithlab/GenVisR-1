#' Plot a mutation heatmap
#'
#' Plot a Mutation Landscape with variables sample, gene, mutation
#' @name waterfall_buildMain
#' @param data_frame a data frame in MAF format
#' @param grid boolean value whether to overlay a grid on the plot
#' @param label_x boolean value whether to label the x axis
#' @param gene_label_size numeric value indicating the size of the gene labels
#' on the y-axis
#' @param file_type character string specifying the file type, one of 'MAF' or
#' 'MGI'
#' @param drop_mutation Boolean specifying whether to drop unused
#' "mutation type" levels from the legend
#' @param plot_x_title Boolean specifying whether to plot the x_axis title
#' @param plot_label Boolean specifying whether to plot text inside each cell
#' @param plot_label_size Integer specifying text size of cell labels
#' @param plot_palette Character vector specifying colors to fill on mutation
#' type
#' @param layers additional ggplot2 layers to plot
#' @param plot_label_angle angle at which to plot label text if plot_label is
#' true
#' @return a ggplot2 object
#' @import ggplot2

waterfall_buildMain <- function(data_frame, grid=TRUE, label_x=FALSE,
                                gene_label_size=8, file_type='MGI',
                                drop_mutation=FALSE, plot_x_title=TRUE,
                                plot_label=FALSE, plot_label_size=4,
                                plot_palette=NULL, layers=NULL,
                                plot_label_angle=0)
{
    # NOTE: scale_x_discret(drop=FALSE), added to ggplot2 call to ensure samples
    # remove by 'mutation_recurrence_subset' are still plotted as empty tiles

    # Define layers

    # grid overlay
    vertical_grid <- geom_vline(xintercept = seq(.5, nlevels(data_frame$sample),
                                                 by=1),
                                linetype='solid', colour='grey80', size=.01)

    if(length(unique(data_frame$gene)) == 1)
    {
        horizontal_grid <- geom_blank()
    } else {
        horizontal_grid <- geom_hline(yintercept = seq(1.5, length(unique(data_frame$gene)),
                                                       by=1),
                                      linetype='solid', colour='grey80',
                                      size=.01)
    }

    # Declare the appropriate palette
    if(!is.null(plot_palette))
    {
        palette <- plot_palette
    } else if(toupper(file_type) == toupper('MGI')) {
        palette <- c('#4f00A8', '#A80100', '#CF5A59', '#A80079', '#BC2D94',
                     '#CF59AE', '#000000', '#006666', '#00A8A8', '#009933',
                     '#ace7b9', '#cdf0d5', '#59CF74', '#002AA8', '#5977CF',
                     '#F37812', '#F2B079', '#888811', '#FDF31C', '#8C8C8C')
    } else if(toupper(file_type) == toupper('MAF')) {
        palette <- c("grey", '#A80100', '#CF5A59', '#A80079', '#CF59AE', '#000000',
                     '#9159CF', '#4f00A8', '#59CF74', '#00A8A8', '#79F2F2',
                     '#006666', '#002AA8', '#5977CF', '#F37812', '#F2B079',
                     '#888811', '#FDF31C')
    } else if(toupper(file_type) == toupper('Custom')) {
        memo <- paste0("Defining a palette in main.pallete is recommended ",
                       "when file_type is set to \"Custom\", defaulting to ",
                       "a predefined palette with 20 levels")
        warning(memo)
        palette <- c('#4f00A8', '#A80100', '#CF5A59', '#A80079', '#BC2D94',
                     '#CF59AE', '#000000', '#006666', '#00A8A8', '#009933',
                     '#ace7b9', '#cdf0d5', '#59CF74', '#002AA8', '#5977CF',
                     '#F37812', '#F2B079', '#888811', '#FDF31C', '#8C8C8C')
    }

    # Create breaks specific and labels for specified file type
    if(toupper(file_type) == toupper('MGI'))
    {
        # Create Legend labels
        breaks <- c("nonsense", "frame_shift_del", "frame_shift_ins",
                    "splice_site_del", "splice_site_ins", "splice_site",
                    "nonstop", "in_frame_del", "in_frame_ins", "missense",
                    "splice_region_del", "splice_region_ins",
                    "splice_region", "5_prime_flanking_region",
                    "3_prime_flanking_region", "3_prime_untranslated_region",
                    "5_prime_untranslated_region", "rna", "intronic", "silent")
        labels <- c("Nonsense", "Frame Shift Deletion", "Frame Shift Insertion",
                    "Splice Site Deletion", "Splice Site Insertion",
                    "Splice Site", "Stop Loss", "In Frame Deletion",
                    "In Frame Insertion", "Missense", "Splice Region Insertion",
                    "Splice Region Deletion", "Splice Region",
                    "5' Flank", "3' Flank", "3' UTR", "5' UTR", "RNA",
                    "Intronic", "Silent")
    } else if(toupper(file_type) == toupper('MAF')) {
        # Create Legend Labels
        breaks <- c("Nonsense_Mutation", "Frame_Shift_Ins", "Frame_Shift_Del",
                    "In_Frame_Ins", "In_Frame_Del", "Nonstop_Mutation",
                    "Translation_Start_Site", "Splice_Site", "Missense_Mutation",
                    "5\'Flank", "3\'Flank", "5\'UTR", "3\'UTR", "RNA", "Intron",
                    "IGR", "Silent", "Targeted_Region")
        labels <- c("Nonsense", "Frame Shift Insertion", "Frame Shift Deletion",
                    "In Frame Insertion", "In Frame Deletion", "Nonstop",
                    "Translation Start Site", "Splice Site", "Missense",
                    "5' Flank", "3' Flank", "5' UTR", "3' UTR", "RNA", "Intron",
                    "Intergenic Region", "Silent", "Targeted Region")
    } else if(toupper(file_type) == toupper('Custom')) {
        breaks <- levels(data_frame$trv_type)
        labels <- breaks
    }

    if(drop_mutation == TRUE)
    {
        # Create Legend
        legend <- scale_fill_manual(name="Mutation Type", values=palette,
                                    breaks=breaks, labels=labels, drop=TRUE)
    } else if (drop_mutation == FALSE) {
        # Create Legend
        legend <- scale_fill_manual(name="Mutation Type", values=palette,
                                    breaks=breaks, labels=labels, drop=FALSE)
    }

    # X Label
    x_label <- xlab(paste0('Sample (n=', nlevels(data_frame$sample), ')'))

    if(plot_label == TRUE)
    {
        label <- geom_text(data=data_frame,
                           mapping=aes_string(x='sample', y='gene',
                                              label='label'),
                           size=plot_label_size, colour='white',
                           angle=plot_label_angle)
    } else {
        label <- geom_blank()
    }

    # Theme, Boolean, if specified to plot x labels, define theme such that
    # labels are plotted
    if(label_x == TRUE & plot_x_title == TRUE)
    {
        theme <-  theme(axis.ticks=element_blank(),
                        panel.grid.major=element_blank(),
                        panel.grid.minor=element_blank(),
                        panel.background=element_rect(fill='white',
                                                      colour='white'),
                        axis.text.x=element_text(angle=50, hjust=1),
                        axis.text.y=element_text(size=gene_label_size,
                                                 colour='black', face='italic'),
                        axis.title.y=element_blank(),
                        axis.title.x=element_text(size=10),
                        legend.title=element_text(size=14),
                        plot.title=element_blank())
    } else if(label_x == FALSE & plot_x_title == TRUE) {
        theme <-  theme(axis.ticks=element_blank(),
                        panel.grid.major=element_blank(),
                        panel.grid.minor=element_blank(),
                        panel.background=element_rect(fill='white',
                                                      colour='white'),
                        axis.text.x=element_blank(),
                        axis.text.y=element_text(size=gene_label_size,
                                                 colour='black', face='italic'),
                        axis.title.y=element_blank(),
                        axis.title.x=element_text(size=20),
                        legend.title=element_text(size=14),
                        plot.title=element_blank(),
                        panel.border=element_rect(colour='grey80', fill=NA,
                                                  size=.1),
                        legend.position=("right"))
    } else if(label_x == TRUE & plot_x_title == FALSE) {
        theme <-  theme(axis.ticks=element_blank(),
                        panel.grid.major=element_blank(),
                        panel.grid.minor=element_blank(),
                        panel.background=element_rect(fill='white',
                                                      colour='white'),
                        axis.text.x=element_text(angle=50, hjust=1),
                        axis.text.y=element_text(size=gene_label_size,
                                                 colour='black', face='italic'),
                        axis.title.y=element_blank(),
                        axis.title.x=element_blank(),
                        legend.title=element_text(size=14),
                        plot.title=element_blank())
    } else if(label_x == FALSE & plot_x_title == FALSE) {
        theme <-  theme(axis.ticks=element_blank(),
                        panel.grid.major=element_blank(),
                        panel.grid.minor=element_blank(),
                        panel.background=element_rect(fill='white',
                                                      colour='white'),
                        axis.text.x=element_blank(),
                        axis.text.y=element_text(size=gene_label_size,
                                                 colour='black', face='italic'),
                        axis.title.y=element_blank(),
                        axis.title.x=element_blank(),
                        legend.title=element_text(size=14),
                        plot.title=element_blank(),
                        panel.border=element_rect(colour='grey80', fill=NA,
                                                  size=.1),
                        legend.position=("right"))
    }

    # additional parameters
    if(!is.null(layers))
    {
        layers <- layers
    } else {
        layers <- geom_blank()
    }

    # ggplot call
    if(grid == TRUE)
    {
        p1 <- ggplot(data_frame, aes_string('sample', 'gene')) +
        geom_tile(aes_string(fill='trv_type'), position="identity") +
        theme + legend + ggtitle(title) + x_label + vertical_grid +
        horizontal_grid + scale_x_discrete(drop=FALSE) + label +
        layers
    } else {
        p1 <- ggplot(data_frame, aes_string('sample', 'gene')) +
        geom_tile(aes_string(fill='trv_type'), position="identity") +
        theme + legend + ggtitle(title) + x_label +
        scale_x_discrete(drop=FALSE) + label + layers
    }

    return(p1)
}
