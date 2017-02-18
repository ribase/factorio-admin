<?php

namespace Ribase\Controller;

use Ribase\Options\Settings;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\Serializer\Serializer;
use Symfony\Component\Serializer\Encoder\XmlEncoder;
use Symfony\Component\Serializer\Encoder\JsonEncoder;
use Symfony\Component\Serializer\Normalizer\ObjectNormalizer;

class MapGenSettingsController extends Controller
{

    /**
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\Response
     * @Route("/map-gen-settings", name="MapGenSettings")
     */
    public function listAction(Request $request)
    {


        $form = $this->createFormBuilder()
            ->setMethod('POST')
            ->getForm();

        if ($request->isMethod('POST')) {
            $form->submit($request->request->get($form->getName()));

            if ($form->isSubmitted()) {
                $content = $request->request->get('form');
                
                $result = $this->saveAction($content);

            }
        }

        $string = file_get_contents($this->getMapSettings());
        $json_a = json_decode($string, true);

        $view = $json_a;

        return $this->render('admin/map-gen-settings.html.twig', array(
            'view' => $view,
            'form' => $form->createView(),
        ));
    }

    /**
     * @param $content
     * @return bool
     */
    public function saveAction($content)
    {

        $encoders = array(new XmlEncoder(), new JsonEncoder());
        $normalizers = array(new ObjectNormalizer());

        $serializer = new Serializer($normalizers, $encoders);

        $jsonContent = $serializer->serialize($content, 'json');

        $fs = new Filesystem();

        $fs->dumpFile($this->getMapSettings(), $jsonContent);

        return true;

    }

    /**
     * @return string
     */
    private function getMapSettings()
    {
        $settings = new Settings();

        return $settings->getMapSettings();
    }

}

