classdef ReportResult < handle

    properties (Access = private)

        % Result output location
        ResultLocation openmebius.domain.result.ResultLocation

        % Objects
        model
        exp
        result

        % filename
        filename = ""

        % rpt
        rpt

        % TitlePage
        title = "Result Comparison"
        subtitle = ""
        author = "Tatsumi Imada"

    end

    methods (Access = public)

        function obj = ReportResult(fileDirectory, model, exp, result)

            obj.ResultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                fileDirectory);
            obj.model = model;
            obj.exp = exp;
            obj.result = result;

            if model.isError || exp.isError || result.isError
                return;
            end

            setupReport(obj);
            addTitlePage(obj);
            addTableOfContents(obj);

            addModelInfo(obj);

            rptview(obj.rpt);

        end % ReportResult

    end % public methods

    methods (Access = public)

        function setupReport(obj)

            import mlreportgen.report.Report;

            generateFilename(obj, "summary");
            obj.rpt = Report(obj.filename, "html");
            obj.rpt.Layout.Landscape = true;

        end % setupReport

        function generateFilename(obj, filename)

            obj.filename = obj.ResultLocation.reportFile(filename);

        end % generateFilename

        function addTitlePage(obj)

            import mlreportgen.report.TitlePage;

            tp = TitlePage;
            tp.Title = obj.title;
            tp.Subtitle = obj.subtitle;
            tp.Author = obj.author;
            add(obj.rpt, tp);

        end % addTitlePage

        function addTableOfContents(obj)

            import mlreportgen.report.TableOfContents;

            toc = TableOfContents;
            add(obj.rpt, toc);

        end % addTableOfContents

        function table = addTable(~, data)

            import mlreportgen.dom.FormalTable;

            table = FormalTable(data);

        end % addTable

        function addModelInfo(obj)

            import mlreportgen.report.Chapter;
            import mlreportgen.report.Section;

            chapter = Chapter("Model Information");
            sec1 = addModelInfoInfo(obj);
            sec2 = addModelInfoList(obj);
            sec3 = addModelInfoTransition(obj);
            sec4 = addModelInfoBiomass(obj);
            sec5 = addModelInfoStoichiometry(obj);

            add(chapter, sec1);
            add(chapter, sec2);
            add(chapter, sec3);
            add(chapter, sec4);
            add(chapter, sec5);

            add(obj.rpt, chapter);

        end % addModelInfo

        function section = addModelInfoInfo(obj)

            import mlreportgen.report.Section;

            section = Section("Model Information");

            infoList = obj.model.tableInfo;

            table = addTable(obj, infoList);

            add(section, table);

        end % addModelInfoInfo

        function section = addModelInfoList(obj)

            import mlreportgen.report.Section;
            import mlreportgen.dom.FormalTable;

            section = Section("Metabolic Network");

            modelList = obj.model.tableModel;

            table = addTable(obj, modelList);

            add(section, table);

        end % addModelInfoList

        function section = addModelInfoTransition(obj)

            import mlreportgen.report.Section;

            section = Section("Carbon Transition");

            transitionList = obj.model.tableMS;

            table = addTable(obj, transitionList);

            add(section, table);

        end % addModelInfoTransition

        function section = addModelInfoBiomass(obj)

            import mlreportgen.report.Section;

            section = Section("Biomass");

            biomassList = obj.model.tableBiomass;

            table = addTable(obj, biomassList);

            add(section, table);

        end % addModelInfoBiomass

        function section = addModelInfoStoichiometry(obj)

            import mlreportgen.report.Section;

            section = Section("Stoichiometry");

            stoichiometryList = obj.model.SBefore;

            table = addTable(obj, stoichiometryList);

            add(section, table);

        end % addstoichiometry

    end

end
