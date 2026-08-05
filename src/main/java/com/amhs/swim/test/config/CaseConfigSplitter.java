package com.amhs.swim.test.config;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/** One-time development utility to split the legacy combined case catalog. */
public final class CaseConfigSplitter {
    private CaseConfigSplitter() { }

    public static void main(String[] args) throws Exception {
        Path source = Paths.get("config/default_case_payloads.xml");
        Path outputDirectory = Paths.get("config/cases");
        Files.createDirectories(outputDirectory);

        Document sourceDocument = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(source.toFile());
        Transformer transformer = TransformerFactory.newInstance().newTransformer();
        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");

        org.w3c.dom.NodeList cases = sourceDocument.getDocumentElement().getElementsByTagName("case");
        for (int i = 0; i < cases.getLength(); i++) {
            Element sourceCase = (Element) cases.item(i);
            String caseId = sourceCase.getAttribute("id");
            if (caseId.isEmpty()) continue;

            Document caseDocument = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
            Element copiedCase = (Element) caseDocument.importNode(sourceCase, true);
            boolean hasRecipients = false;
            org.w3c.dom.NodeList configs = copiedCase.getElementsByTagName("config");
            for (int configIndex = 0; configIndex < configs.getLength(); configIndex++) {
                if ("amhs_recipients".equals(((Element) configs.item(configIndex)).getAttribute("key"))) {
                    hasRecipients = true;
                    break;
                }
            }
            if (!hasRecipients) {
                Element recipients = caseDocument.createElement("config");
                recipients.setAttribute("key", "amhs_recipients");
                recipients.setTextContent("VVTSYMYX");
                copiedCase.appendChild(recipients);
            }
            caseDocument.appendChild(copiedCase);
            transformer.transform(new DOMSource(caseDocument),
                                  new StreamResult(outputDirectory.resolve(caseId + ".xml").toFile()));
        }
    }
}
